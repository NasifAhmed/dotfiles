package ui

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
	"path/filepath"

	"github.com/charmbracelet/bubbles/list"
	"github.com/charmbracelet/bubbles/spinner"
	"github.com/charmbracelet/bubbles/textinput"
	"github.com/charmbracelet/bubbles/viewport"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"

	"dotman/internal/git"
	"dotman/internal/stow"
	"dotman/internal/utils"
)

type SessionState int

const (
	StateDashboard SessionState = iota
	StateProfileSelect
	StateCreateProfile
	StateProfileView
	StateAddConfigPath
	StateStorage
	StateStoragePath
	StateReset
	StateConfirm
)

type Model struct {
	State       SessionState
	Spinner     spinner.Model
	List        list.Model
	Viewport    viewport.Model
	Input       textinput.Model

	// Services
	Git    *git.GitManager
	Stow   *stow.StowManager
	Logger *utils.Logger

	// Data
	GitStatus      string
	GitSyncStatus  string
	CurrentProfile string
	Logs           []string
	RepoRoot       string
	Width, Height  int
	
	// Dashboard Info
	LastCommitMsg  string
	CommitHash     string
	Distro         string

	// For specific actions
	FilesToReset    []string
	SelectedProfile string
	TempName        string // To store name between steps
	ConfirmAction   func() tea.Cmd
	ConfirmMsg      string
}

func InitialModel(root string) Model {
	s := spinner.New()
	s.Spinner = spinner.Pulse // Cooler animation
	s.Style = lipgloss.NewStyle().Foreground(lipgloss.AdaptiveColor{Light: "#FF00FF", Dark: "#04B575"})

	l := list.New([]list.Item{}, list.NewDefaultDelegate(), 0, 0)
	l.SetShowHelp(false)

	vp := viewport.New(0, 0)

	ti := textinput.New()
	ti.Placeholder = "Type here..."

	gitMgr := git.NewGitManager(root)
	stowMgr := stow.NewStowManager(root)
	logger := utils.NewLogger(root)

	currentProf := "None"
	if data, err := os.ReadFile(strings.TrimSpace(root) + "/.current_profile"); err == nil {
		currentProf = strings.TrimSpace(string(data))
	}

	return Model{
		State:          StateDashboard,
		Spinner:        s,
		List:           l,
		Viewport:       vp,
		Input:          ti,
		Git:            gitMgr,
		Stow:           stowMgr,
		Logger:         logger,
		Logs:           []string{"Dotman Initialized...", fmt.Sprintf("Root: %s", root)},
		RepoRoot:       root,
		CurrentProfile: currentProf,
		Distro:         utils.GetDistroInfo(),
	}
}

func (m Model) Init() tea.Cmd {
	return tea.Batch(
		m.Spinner.Tick,
		m.fetchGitStatus(),
		m.fetchCommitInfo(),
	)
}

type CommitInfoMsg struct {
	Hash, Msg string
}

func (m Model) fetchCommitInfo() tea.Cmd {
	return func() tea.Msg {
		h, msg, _ := m.Git.GetLastCommit()
		return CommitInfoMsg{Hash: h, Msg: msg}
	}
}

// Messages
type LogMsg string
type StatusMsg struct {
	Pending int
	Sync    string
}
type ProfileAppliedMsg string
type FilesListMsg []string
type SyncResultMsg []string

func (m Model) fetchGitStatus() tea.Cmd {
	return func() tea.Msg {
		sync, pending, err := m.Git.GetStatus()
		if err != nil {
			return LogMsg(fmt.Sprintf("Git status error: %v", err))
		}
		return StatusMsg{Pending: pending, Sync: sync}
	}
}

// Sync Command Chain
type SyncMsg struct {
	Step string
	Logs []string
	Err  error
}

func (m Model) cmdSyncFetch() tea.Cmd {
	return func() tea.Msg {
		var logs []string
		logs = append(logs, "Fetching from origin...")
		err := m.Git.Fetch(&logs)
		return SyncMsg{Step: "fetch", Logs: logs, Err: err}
	}
}

func (m Model) cmdSyncCheck() tea.Cmd {
	return func() tea.Msg {
		var logs []string
		branch, err := m.Git.GetCurrentBranch(&logs)
		if err != nil { return SyncMsg{Step: "check", Logs: logs, Err: err} }
		
		behind, ahead, err := m.Git.CheckDivergence(branch, &logs)
		
		// Check for pending changes
		_, pending, _ := m.Git.GetStatus()
		
		logs = append(logs, fmt.Sprintf("Status: Behind %d, Ahead %d, Pending %d", behind, ahead, pending))
		
		// Decide next step
		next := "done"
		if behind > 0 {
			next = "pull"
		} else if ahead > 0 || pending > 0 {
			next = "push"
		}
		
		return SyncMsg{Step: next, Logs: logs, Err: err}
	}
}

func (m Model) cmdSyncPull() tea.Cmd {
	return func() tea.Msg {
		var logs []string
		logs = append(logs, "Pulling changes...")
		branch, _ := m.Git.GetCurrentBranch(&logs) // assume valid
		err := m.Git.Pull(branch, &logs)
		
		next := "push" // Try push after pull just in case we have local changes too
		if err != nil { next = "error" }
		
		return SyncMsg{Step: next, Logs: logs, Err: err}
	}
}

func (m Model) cmdSyncPush() tea.Cmd {
	return func() tea.Msg {
		var logs []string
		logs = append(logs, "Pushing changes...")
		branch, _ := m.Git.GetCurrentBranch(&logs)
		err := m.Git.Push(branch, &logs)
		return SyncMsg{Step: "done", Logs: logs, Err: err}
	}
}

func (m Model) applyProfile(name string) tea.Cmd {
	return func() tea.Msg {
		logs, err := m.Stow.StowProfile(name)
		
		// Join logs for display
		fullLog := strings.Join(logs, "\n")
		
		if err != nil {
			return LogMsg(fmt.Sprintf("Profile Apply Failed:\n%s\nError: %v", fullLog, err))
		}
		
		// Reload Hyprland
		if _, err := exec.LookPath("hyprctl"); err == nil {
			exec.Command("hyprctl", "reload").Run()
		}

		// Save current profile
		os.WriteFile(m.RepoRoot+"/.current_profile", []byte(name), 0644)

		return ProfileAppliedMsg(name)
	}
}

func (m Model) loadResetFiles() tea.Cmd {
	return func() tea.Msg {
		files, err := m.Git.GetUncommittedFiles()
		if err != nil {
			return LogMsg(fmt.Sprintf("Error listing files: %v", err))
		}
		return FilesListMsg(files)
	}
}

func (m Model) resetFile(file string) tea.Cmd {
	return func() tea.Msg {
		if err := m.Git.ResetFile(file); err != nil {
			return LogMsg(fmt.Sprintf("Failed to reset %s: %v", file, err))
		}
		return LogMsg(fmt.Sprintf("Reset %s", file))
	}
}

func (m Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	var cmd tea.Cmd
	var cmds []tea.Cmd

	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch m.State {
		case StateDashboard:
			switch msg.String() {
			case "q", "ctrl+c":
				return m, tea.Quit
			case "s":
				m.Logs = append(m.Logs, "Initiating Smart Sync...")
				m.GitSyncStatus = "Syncing..."
				return m, tea.Batch(m.cmdSyncFetch(), m.Spinner.Tick)
			case "p":
				m.State = StateProfileSelect
				m.List.Title = "Manage Profiles (Enter: Apply, v: View, d: Delete)"
				profiles := m.Stow.GetProfiles()
				items := make([]list.Item, len(profiles))
				for i, p := range profiles {
					items[i] = Item{title: p, desc: "Profile"}
				}
				m.List.SetItems(items)
				m.List.ResetSelected()
			case "o": // Storage
				m.State = StateStorage
				m.List.Title = "Storage (c: Create, d: Delete)"
				files := m.Stow.GetStorageFiles()
				items := make([]list.Item, len(files))
				for i, f := range files {
					items[i] = Item{title: f, desc: "File/Dir"}
				}
				m.List.SetItems(items)
				m.List.ResetSelected()
			case "r": // Reset
				m.State = StateReset
				m.List.Title = "Select File to Reset"
				return m, m.loadResetFiles()
			}

		case StateProfileSelect:
			switch msg.String() {
			case "esc":
				m.State = StateDashboard
				return m, nil
			case "enter":
				i, ok := m.List.SelectedItem().(Item)
				if ok {
					m.State = StateDashboard
					return m, m.applyProfile(i.title)
				}
			case "c":
				m.State = StateCreateProfile
				m.Input.Reset()
				m.Input.Placeholder = "New Profile Name"
				m.Input.Focus()
			case "v":
				i, ok := m.List.SelectedItem().(Item)
				if ok {
					m.SelectedProfile = i.title
					m.State = StateProfileView
					packages, _ := m.Stow.GetProfilePackages(i.title)
					items := make([]list.Item, len(packages))
					for idx, p := range packages {
						items[idx] = Item{title: p, desc: "Package"}
					}
					m.List.SetItems(items)
					m.List.Title = fmt.Sprintf("Packages in %s (a: Add Config, d: Delete, esc: Back)", i.title)
				}
			case "d":
				i, ok := m.List.SelectedItem().(Item)
				if ok {
					m.State = StateConfirm
					m.ConfirmMsg = fmt.Sprintf("Delete profile '%s'? (y/n)", i.title)
					m.ConfirmAction = func() tea.Cmd {
						m.Stow.DeleteProfile(i.title)
						return func() tea.Msg { return LogMsg(fmt.Sprintf("Deleted profile %s", i.title)) }
					}
				}
			}
			m.List, cmd = m.List.Update(msg)
			cmds = append(cmds, cmd)

		case StateProfileView:
			switch msg.String() {
			case "esc":
				m.State = StateProfileSelect
				// Reload profiles list
				profiles := m.Stow.GetProfiles()
				items := make([]list.Item, len(profiles))
				for i, p := range profiles {
					items[i] = Item{title: p, desc: "Profile"}
				}
				m.List.SetItems(items)
				m.List.Title = "Manage Profiles"
				return m, nil
			case "a":
				m.State = StateAddConfigPath
				m.Input.Reset()
				m.Input.Placeholder = "Source Path (e.g. ~/.config/nvim)"
				m.Input.Focus()
			case "d":
				i, ok := m.List.SelectedItem().(Item)
				if ok {
					m.State = StateConfirm
					m.ConfirmMsg = fmt.Sprintf("Delete package '%s' and restore files? (y/n)", i.title)
					m.ConfirmAction = func() tea.Cmd {
						// DeletePackage does Restore
						if err := m.Stow.DeletePackage(m.SelectedProfile, i.title, &m.Logs); err != nil {
							return func() tea.Msg { return LogMsg(fmt.Sprintf("Error deleting package: %v", err)) }
						}
						// Refresh List
						packages, _ := m.Stow.GetProfilePackages(m.SelectedProfile)
						items := make([]list.Item, len(packages))
						for idx, p := range packages {
							items[idx] = Item{title: p, desc: "Package"}
						}
						m.List.SetItems(items)
						return func() tea.Msg { return LogMsg(fmt.Sprintf("Restored and deleted package %s", i.title)) }
					}
				}
			}
			m.List, cmd = m.List.Update(msg)
			cmds = append(cmds, cmd)

				case StateAddConfigPath:
					if msg.String() == "esc" {
						m.State = StateProfileView
						m.Input.Blur()
						return m, nil
					}
					if msg.String() == "enter" {
						path := m.Input.Value()
						if path != "" {
							fullPath, err := utils.ExpandPath(path)
							if err != nil {
								m.Logs = append(m.Logs, fmt.Sprintf("Error expanding path: %v", err))
								m.Input.Reset()
								return m, nil
							}
		
							// Verify path exists
							if _, err := os.Stat(fullPath); os.IsNotExist(err) {
								m.Logs = append(m.Logs, fmt.Sprintf("Error: Path does not exist: %s", fullPath))
								m.Input.Reset() // Clear to let user try again
								return m, nil
							}
		
							if err == nil {
								// Auto-derive name from path base
								pkgName := filepath.Base(fullPath)
								if pkgName == "." || pkgName == "/" {
									pkgName = "root_config"
								}
								// Pass logs pointer
								err = m.Stow.ImportPackage(m.SelectedProfile, pkgName, fullPath, &m.Logs)
								m.TempName = pkgName 
							}
							
							if err != nil {
								m.Logs = append(m.Logs, fmt.Sprintf("Error importing: %v", err))
							} else {
								m.Logs = append(m.Logs, fmt.Sprintf("Successfully imported and stowed '%s'", m.TempName))
							}
							
							// Return to view
							m.State = StateProfileView
							m.Input.Blur()
							packages, _ := m.Stow.GetProfilePackages(m.SelectedProfile)
							items := make([]list.Item, len(packages))
							for idx, p := range packages {
								items[idx] = Item{title: p, desc: "Package"}
							}
							m.List.SetItems(items)
							return m, nil
						}
					}
					m.Input, cmd = m.Input.Update(msg)
					cmds = append(cmds, cmd)
		
				case StateStorage:
					switch msg.String() {
					case "esc":
						m.State = StateDashboard
						return m, nil
					case "c": // Import/Create
						m.State = StateStoragePath
						m.Input.Reset()
						m.Input.Placeholder = "Source Path (File or Dir)"
						m.Input.Focus()
					case "d":
						i, ok := m.List.SelectedItem().(Item)
						if ok {
							m.State = StateConfirm
							m.ConfirmMsg = fmt.Sprintf("Delete storage item '%s'? (y/n)", i.title)
							m.ConfirmAction = func() tea.Cmd {
								m.Stow.DeleteStorageItem(i.title, &m.Logs)
								return func() tea.Msg { return LogMsg(fmt.Sprintf("Deleted storage item %s", i.title)) }
							}
						}
					}
					m.List, cmd = m.List.Update(msg)
					cmds = append(cmds, cmd)
		
				case StateStoragePath:
					if msg.String() == "esc" {
						m.State = StateStorage
						m.Input.Blur()
						return m, nil
					}
					if msg.String() == "enter" {
						path := m.Input.Value()
						if path != "" {
							fullPath, err := utils.ExpandPath(path)
							if err != nil {
								m.Logs = append(m.Logs, fmt.Sprintf("Error expanding path: %v", err))
								m.Input.Reset()
								return m, nil
							}
		
							// Verify path exists
							if _, err := os.Stat(fullPath); os.IsNotExist(err) {
								m.Logs = append(m.Logs, fmt.Sprintf("Error: Path does not exist: %s", fullPath))
								m.Input.Reset()
								return m, nil
							}
		
							if err == nil {
								// Auto-derive name
								name := filepath.Base(fullPath)
								// Pass logs pointer
								err = m.Stow.CreateStorageItem(name, fullPath, &m.Logs)
								m.TempName = name
							}
		
							if err != nil {
								m.Logs = append(m.Logs, fmt.Sprintf("Error importing storage: %v", err))
							} else {
								m.Logs = append(m.Logs, fmt.Sprintf("Successfully imported and linked storage: %s", m.TempName))
							}
							// Return to storage list
							m.State = StateStorage
							m.Input.Blur()
							files := m.Stow.GetStorageFiles()
							items := make([]list.Item, len(files))
							for i, f := range files {
								items[i] = Item{title: f, desc: "File/Dir"}
							}
							m.List.SetItems(items)
							return m, nil
						}
					}
					m.Input, cmd = m.Input.Update(msg)
					cmds = append(cmds, cmd)
				case StateConfirm:
			switch msg.String() {
			case "y":
				action := m.ConfirmAction
				m.State = StateDashboard // Or back to previous? Let's go Dashboard for safety/simplicity
				return m, action()
			case "n", "esc":
				m.State = StateDashboard
				return m, nil
			}

		case StateCreateProfile:
			if msg.String() == "esc" {
				m.State = StateProfileSelect // Back to profile list
				m.Input.Blur()
				return m, nil
			}
			if msg.String() == "enter" {
				name := m.Input.Value()
				if name != "" {
					m.State = StateProfileSelect // Back to profile list
					err := m.Stow.CreateProfile(name)
					if err != nil {
						m.Logs = append(m.Logs, fmt.Sprintf("Error creating profile: %v", err))
					} else {
						m.Logs = append(m.Logs, fmt.Sprintf("Created profile: %s", name))
					}
					// Refresh list
					profiles := m.Stow.GetProfiles()
					items := make([]list.Item, len(profiles))
					for i, p := range profiles {
						items[i] = Item{title: p, desc: "Profile"}
					}
					m.List.SetItems(items)
					
					return m, nil
				}
			}
			m.Input, cmd = m.Input.Update(msg)
			cmds = append(cmds, cmd)

		case StateReset:
			if msg.String() == "esc" {
				m.State = StateDashboard
				return m, nil
			}
			if msg.String() == "enter" {
				i, ok := m.List.SelectedItem().(Item)
				if ok {
					return m, tea.Batch(m.resetFile(i.title), m.loadResetFiles())
				}
			}
			m.List, cmd = m.List.Update(msg)
			cmds = append(cmds, cmd)
		}

	case tea.WindowSizeMsg:
		m.Width, m.Height = msg.Width, msg.Height
		headerHeight := 8
		footerHeight := 3
		m.Viewport.Width = msg.Width - 4
		m.Viewport.Height = msg.Height - headerHeight - footerHeight
		m.List.SetSize(msg.Width-4, msg.Height-4)

	case spinner.TickMsg:
		m.Spinner, cmd = m.Spinner.Update(msg)
		cmds = append(cmds, cmd)

	case LogMsg:
		m.Logs = append(m.Logs, string(msg))
		if len(m.Logs) > 100 { m.Logs = m.Logs[len(m.Logs)-100:] }
		m.Viewport.SetContent(strings.Join(m.Logs, "\n"))
		m.Viewport.GotoBottom()
		m.Logger.Log(string(msg))

	case SyncMsg:
		// Append logs
		for _, l := range msg.Logs {
			m.Logs = append(m.Logs, l)
			m.Logger.Log(l)
		}
		m.Viewport.SetContent(strings.Join(m.Logs, "\n"))
		m.Viewport.GotoBottom()

		if msg.Err != nil {
			m.Logs = append(m.Logs, fmt.Sprintf("Sync Error: %v", msg.Err))
			m.GitSyncStatus = "Sync Error"
			return m, nil
		}

		// Chain next step
		switch msg.Step {
		case "fetch":
			return m, m.cmdSyncCheck()
		case "check":
			// Decision logic was in cmdSyncCheck, determining 'next' step
			// but we need to handle specific next steps here?
			// Wait, cmdSyncCheck returned the *next step name* in msg.Step.
			// Ah, I see. cmdSyncCheck returned "pull", "push", or "done".
			// So we just need to route it.
			// But wait, my switch case is on msg.Step (which is the result of the *previous* command).
			// No, logic in cmdSyncCheck returned the *next* action to take.
			// But SyncMsg.Step usually denotes "what just finished".
			// Let's correct: cmdSyncCheck returns "check" as step?
			// RE-READ my code:
			// cmdSyncCheck returns SyncMsg{Step: next, ...} where next is "pull", "push", or "done".
			// So if I receive a message with Step="pull", it means "please pull".
			// This is slightly confusing naming. Let's assume msg.Step is "Next Action".
			// BUT cmdSyncFetch returned Step="fetch". 
			// So: 
			// 1. cmdSyncFetch returns msg with Step="fetch".
			// 2. Case "fetch" -> run cmdSyncCheck.
			// 3. cmdSyncCheck returns msg with Step="pull" or "push" or "done".
			// 4. Case "pull" -> run cmdSyncPull.
			// 5. cmdSyncPull returns msg with Step="push" or "done".
			// 6. Case "push" -> run cmdSyncPush.
			// 7. cmdSyncPush returns msg with Step="done".
			// 8. Case "done" -> refresh status.
			
			// This flow works if I implement it right here.
		}
		
		switch msg.Step {
		case "fetch":
			return m, m.cmdSyncCheck()
		case "pull":
			return m, m.cmdSyncPull()
		case "push":
			return m, m.cmdSyncPush()
		case "done":
			m.Logs = append(m.Logs, "Sync Completed.")
			m.GitSyncStatus = "Synced"
			return m, tea.Batch(m.fetchGitStatus(), m.fetchCommitInfo())
		case "error":
			m.GitSyncStatus = "Sync Failed"
		}

	case StatusMsg:
		m.GitStatus = fmt.Sprintf("%d pending", msg.Pending)
		m.GitSyncStatus = msg.Sync

	case CommitInfoMsg:
		m.CommitHash = msg.Hash
		m.LastCommitMsg = msg.Msg

	case ProfileAppliedMsg:
		m.CurrentProfile = string(msg)
		msgStr := fmt.Sprintf("Success: Applied profile %s", msg)
		m.Logs = append(m.Logs, msgStr)
		m.Logger.Log(msgStr)
		m.Viewport.SetContent(strings.Join(m.Logs, "\n"))
		m.Viewport.GotoBottom()
		
	case FilesListMsg:
		items := make([]list.Item, len(msg))
		for i, f := range msg {
			items[i] = Item{title: f, desc: "Modified"}
		}
		m.List.SetItems(items)
	}

	return m, tea.Batch(cmds...)
}

type Item struct {
	title, desc string
}

func (i Item) Title() string       { return i.title }
func (i Item) Description() string { return i.desc }
func (i Item) FilterValue() string { return i.title }
