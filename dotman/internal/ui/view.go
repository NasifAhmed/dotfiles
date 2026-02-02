package ui

import (
	"fmt"
	"os"
	"strings"
	"time"

	"github.com/charmbracelet/lipgloss"
)

var (
	// Colors - Adaptive
	primary   = lipgloss.AdaptiveColor{Light: "#04B575", Dark: "#04B575"} // Greenish
	secondary = lipgloss.AdaptiveColor{Light: "#FF00FF", Dark: "#FF00FF"} // Magenta/Pink
	text      = lipgloss.AdaptiveColor{Light: "#333333", Dark: "#DDDDDD"}
	subtext   = lipgloss.AdaptiveColor{Light: "#666666", Dark: "#999999"}
	bg        = lipgloss.AdaptiveColor{Light: "#F0F0F0", Dark: "#1A1B26"}
	border    = lipgloss.AdaptiveColor{Light: "#AAAAAA", Dark: "#444444"}

	// Styles
	appStyle = lipgloss.NewStyle().Padding(1, 2)

	titleStyle = lipgloss.NewStyle().
		Foreground(primary).
		Background(bg).
		Padding(0, 1).
		Bold(true)

	boxStyle = lipgloss.NewStyle().
		Border(lipgloss.RoundedBorder()).
		BorderForeground(border).
		Padding(0, 1).
		MarginRight(1)

	labelStyle = lipgloss.NewStyle().
		Foreground(subtext).
		Bold(true)
	
	valueStyle = lipgloss.NewStyle().
		Foreground(text)
		
	statusGreen = lipgloss.NewStyle().Foreground(lipgloss.Color("#25A065"))
	statusRed   = lipgloss.NewStyle().Foreground(lipgloss.Color("#FF5555"))
	statusYellow= lipgloss.NewStyle().Foreground(lipgloss.Color("#F1FA8C"))

	logStyle = lipgloss.NewStyle().
		Border(lipgloss.RoundedBorder()).
		BorderForeground(border).
		Padding(0, 1).
		MarginTop(1)
)

func (m Model) View() string {
	if m.State == StateProfileSelect || m.State == StateStorage || m.State == StateReset || m.State == StateProfileView {
		return appStyle.Render(m.List.View())
	}
	
	if m.State == StateCreateProfile {
		return appStyle.Render(fmt.Sprintf(
			"Create New Profile\n\n%s\n\n(Esc to cancel, Enter to create)",
			m.Input.View(),
		))
	}

	if m.State == StateAddConfigPath {
		return appStyle.Render(fmt.Sprintf(
			"Add Config to %s\n\n%s\n\n(Enter Source Path)\n(e.g. ~/.config/nvim)",
			m.SelectedProfile, m.Input.View(),
		))
	}

	if m.State == StateStoragePath {
		return appStyle.Render(fmt.Sprintf(
			"Import to Storage\n\n%s\n\n(Enter Source Path to Copy)",
			m.Input.View(),
		))
	}
	
	if m.State == StateConfirm {
		return appStyle.Render(fmt.Sprintf(
			"\n  %s\n\n  (y/n)",
			lipgloss.NewStyle().Foreground(secondary).Bold(true).Render(m.ConfirmMsg),
		))
	}

	// --- DASHBOARD LAYOUT ---
	
	// 1. Header
	headerText := titleStyle.Render("OMARCHY DOTMAN")
	header := lipgloss.JoinHorizontal(lipgloss.Center, headerText, "   ", m.Spinner.View())

	// 2. Info Panels
	hostname, _ := os.Hostname()
	
	// User Info Box
	userInfo := lipgloss.JoinVertical(lipgloss.Left,
		labelStyle.Render("SYSTEM"),
		valueStyle.Render(fmt.Sprintf("%s @ %s", os.Getenv("USER"), hostname)),
		valueStyle.Render(m.Distro),
	)
	
	// Dotman Status Box
	dotmanStatus := lipgloss.JoinVertical(lipgloss.Left,
		labelStyle.Render("PROFILE"),
		valueStyle.Render(m.CurrentProfile),
		lipgloss.NewStyle().Foreground(secondary).Render(time.Now().Format("Jan 02 15:04")),
	)

	// Git Info Box
	gitColor := statusGreen
	if strings.Contains(m.GitStatus, "pending") && !strings.HasPrefix(m.GitStatus, "0") {
		gitColor = statusYellow
	}
	
	syncColor := statusGreen
	if strings.Contains(m.GitSyncStatus, "↓") || strings.Contains(m.GitSyncStatus, "↑") {
		syncColor = statusYellow
	}

	gitInfo := lipgloss.JoinVertical(lipgloss.Left,
		labelStyle.Render("GIT STATUS"),
		gitColor.Render(m.GitStatus),
		syncColor.Render(m.GitSyncStatus),
		valueStyle.Render(fmt.Sprintf("%s: %s", m.CommitHash, truncate(m.LastCommitMsg, 20))),
	)

	// Row of boxes
	boxes := lipgloss.JoinHorizontal(lipgloss.Top, 
		boxStyle.Render(userInfo),
		boxStyle.Render(dotmanStatus),
		boxStyle.Render(gitInfo),
	)

	// 3. Logs (occupy remaining height)
	// Calculate available height more conservatively
	// Header ~10 lines, Boxes ~5 lines, Help ~2 lines, Padding ~2
	fixedHeight := 20 
	logHeight := m.Height - fixedHeight
	if logHeight < 5 { logHeight = 5 }
	
	// Update log viewport if needed
	logView := logStyle.Height(logHeight).Width(m.Width - 4).Render(m.Viewport.View())

	// 4. Footer / Help
	help := lipgloss.NewStyle().Foreground(subtext).Render(
		" [s] Sync   [p] Profiles   [o] Storage   [r] Reset   [q] Quit")

	return appStyle.Render(lipgloss.JoinVertical(lipgloss.Left,
		header,
		boxes,
		logView,
		help,
	))
}

func truncate(s string, max int) string {
	if len(s) > max {
		return s[:max] + "..."
	}
	return s
}
