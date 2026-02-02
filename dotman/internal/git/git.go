package git

import (
	"fmt"
	"os/exec"
	"strings"
)

type GitManager struct {
	Root string
}

func NewGitManager(root string) *GitManager {
	return &GitManager{Root: root}
}

func (g *GitManager) run(args ...string) (string, error) {
	cmd := exec.Command("git", args...)
	cmd.Dir = g.Root
	out, err := cmd.CombinedOutput()
	// We might want to log this internally or return it.
	// For now, existing callers expect (string, error).
	return strings.TrimSpace(string(out)), err
}

// runWithLog is a helper to append command details to a log slice
func (g *GitManager) runWithLog(logs *[]string, args ...string) (string, error) {
	cmdStr := fmt.Sprintf("git %s", strings.Join(args, " "))
	*logs = append(*logs, fmt.Sprintf("Running: %s", cmdStr))
	
	cmd := exec.Command("git", args...)
	cmd.Dir = g.Root
	out, err := cmd.CombinedOutput()
	output := strings.TrimSpace(string(out))
	
	if output != "" {
		*logs = append(*logs, fmt.Sprintf("Output:\n%s", output))
	}
	if err != nil {
		*logs = append(*logs, fmt.Sprintf("Error: %v", err))
	}
	
	return output, err
}

func (g *GitManager) GetStatus() (string, int, error) {
	// ... (Keep existing GetStatus logic, it's for UI state, not action logging) ...
	// Pending changes
	out, err := g.run("status", "--porcelain")
	if err != nil {
		return "", 0, err
	}
	changes := 0
	if len(out) > 0 {
		changes = strings.Count(out, "\n") + 1
	}

	// Get current branch
	branch, err := g.run("branch", "--show-current")
	if err != nil || branch == "" {
		return "Unknown branch", changes, nil
	}

	// Ahead/Behind
	g.run("fetch", "origin") 
	remoteRef := fmt.Sprintf("origin/%s", branch)
	abOut, err := g.run("rev-list", "--left-right", "--count", remoteRef + "...HEAD")
	
	syncText := "Up to date"
	if err == nil {
		fields := strings.Fields(abOut)
		if len(fields) >= 2 {
			behind := fields[0]
			ahead := fields[1]
			if behind != "0" || ahead != "0" {
				syncText = fmt.Sprintf("↓%s ↑%s", behind, ahead)
			}
		}
	} else {
		syncText = "Remote info unavailable"
	}
	return syncText, changes, nil
}

// ... (GetUncommittedFiles remains same) ...
func (g *GitManager) GetUncommittedFiles() ([]string, error) {
	out, err := g.run("status", "--porcelain")
	if err != nil {
		return nil, err
	}
	if out == "" {
		return []string{}, nil
	}
	lines := strings.Split(out, "\n")
	var files []string
	for _, line := range lines {
		if len(line) > 3 {
			files = append(files, line[3:])
		}
	}
	return files, nil
}

// Sync decomposition
func (g *GitManager) Fetch(logs *[]string) error {
	_, err := g.runWithLog(logs, "fetch", "origin")
	return err
}

func (g *GitManager) GetCurrentBranch(logs *[]string) (string, error) {
	branch, err := g.runWithLog(logs, "branch", "--show-current")
	if err != nil || branch == "" {
		return "", fmt.Errorf("could not determine current branch")
	}
	return branch, nil
}

func (g *GitManager) CheckDivergence(branch string, logs *[]string) (int, int, error) {
	remoteRef := fmt.Sprintf("origin/%s", branch)
	abOut, _ := g.runWithLog(logs, "rev-list", "--left-right", "--count", remoteRef + "...HEAD")
	fields := strings.Fields(abOut)
	behind := 0
	ahead := 0
	if len(fields) >= 2 {
		fmt.Sscanf(fields[0], "%d", &behind)
		fmt.Sscanf(fields[1], "%d", &ahead)
	}
	return behind, ahead, nil
}

func (g *GitManager) Pull(branch string, logs *[]string) error {
	_, err := g.runWithLog(logs, "pull", "--rebase", "--autostash", "-X", "theirs", "origin", branch)
	return err
}

func (g *GitManager) Push(branch string, logs *[]string) error {
	// Auto-commit if needed
	status, _, _ := g.GetStatus()
	if !strings.Contains(status, "0 pending") {
		out, _ := g.run("status", "--porcelain")
		if len(out) > 0 {
			*logs = append(*logs, "Committing pending changes...")
			g.runWithLog(logs, "add", ".")
			msg := fmt.Sprintf("Auto-sync: %s", "Automated commit by Dotman")
			g.runWithLog(logs, "commit", "-m", msg)
		}
	}
	_, err := g.runWithLog(logs, "push", "origin", branch)
	return err
}

// Sync performs the smart sync logic (Monolithic version kept for reference or simple calls)
func (g *GitManager) Sync() ([]string, error) {
	var logs []string
	branch, err := g.GetCurrentBranch(&logs)
	if err != nil { return logs, err }

	if err := g.Fetch(&logs); err != nil { return logs, err }

	behind, ahead, _ := g.CheckDivergence(branch, &logs)
	logs = append(logs, fmt.Sprintf("Status: Behind %d, Ahead %d", behind, ahead))

	if behind > 0 {
		logs = append(logs, "Pulling changes...")
		if err := g.Pull(branch, &logs); err != nil { return logs, err }
	}

	if ahead > 0 || behind > 0 {
		logs = append(logs, "Pushing changes...")
		if err := g.Push(branch, &logs); err != nil { return logs, err }
	}
	return logs, nil
}

func (g *GitManager) ResetFile(file string) error {
	_, err := g.run("checkout", "HEAD", "--", file)
	return err
}

func (g *GitManager) GetLastCommit() (string, string, error) {
	hash, err := g.run("rev-parse", "--short", "HEAD")
	if err != nil {
		return "", "", err
	}
	msg, err := g.run("log", "-1", "--pretty=%s") // %s for subject only
	return hash, strings.TrimSpace(msg), err
}
