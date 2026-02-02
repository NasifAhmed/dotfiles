package main

import (
	"fmt"
	"os"

	tea "github.com/charmbracelet/bubbletea"
	"dotman/internal/ui"
	"dotman/internal/utils"
)

func main() {
	// 1. Get Repo Root
	root, err := utils.GetRepoRoot()
	if err != nil {
		// Fallback: assume current directory if not found (e.g. initial setup)
		root, _ = os.Getwd()
		fmt.Printf("Warning: Could not detect git repo root (%v). Using current dir: %s\n", err, root)
	}

	// 2. Check Dependencies (Optional but good)
	// We assume bootstrap.sh handled it, but let's check PATH
	// pathStatus := utils.EnsureLocalBinInPath(os.Getenv("HOME"))
	// We can log this pathStatus in the UI init.

	// 3. Start UI
	p := tea.NewProgram(ui.InitialModel(root), tea.WithAltScreen())
	if _, err := p.Run(); err != nil {
		fmt.Printf("Error: %v\n", err)
		os.Exit(1)
	}
}

