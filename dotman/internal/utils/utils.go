package utils

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"
)

// Logger handles logging to a file and returning the string for the UI
type Logger struct {
	LogPath string
}

func NewLogger(root string) *Logger {
	return &Logger{
		LogPath: filepath.Join(root, "dotman.log"),
	}
}

func (l *Logger) Log(msg string) string {
	f, _ := os.OpenFile(l.LogPath, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	defer f.Close()
	ts := time.Now().Format("2006-01-02 15:04:05")
	logMsg := fmt.Sprintf("[%s] %s", ts, msg)
	f.WriteString(logMsg + "\n")
	return logMsg
}

// EnsureLocalBinInPath checks if ~/.local/bin is in PATH.
// Note: modifying current shell PATH from a child process is impossible.
// We can only check and suggest or append to RC files.
func EnsureLocalBinInPath(home string) string {
	localBin := filepath.Join(home, ".local", "bin")
	pathEnv := os.Getenv("PATH")
	
	if strings.Contains(pathEnv, localBin) {
		return "PATH OK"
	}

	// Try to find shell config
	shell := os.Getenv("SHELL")
	rcFile := ""
	if strings.Contains(shell, "zsh") {
		rcFile = filepath.Join(home, ".zshrc")
	} else if strings.Contains(shell, "bash") {
		rcFile = filepath.Join(home, ".bashrc")
	}

	if rcFile != "" {
		f, err := os.OpenFile(rcFile, os.O_APPEND|os.O_WRONLY, 0644)
		if err == nil {
			defer f.Close()
			// Check if already added to file to avoid duplicates
			content, _ := os.ReadFile(rcFile)
			if !strings.Contains(string(content), localBin) {
				exportCmd := fmt.Sprintf("\n# Added by Dotman\nexport PATH=\"$PATH:%s\"\n", localBin)
				f.WriteString(exportCmd)
				return fmt.Sprintf("Added %s to %s", localBin, filepath.Base(rcFile))
			}
		}
	}
	return fmt.Sprintf("Warning: %s not in PATH", localBin)
}

func GetDistroInfo() string {
	data, err := os.ReadFile("/etc/os-release")
	if err != nil {
		return "Unknown Linux"
	}
	lines := strings.Split(string(data), "\n")
	for _, line := range lines {
		if strings.HasPrefix(line, "PRETTY_NAME=") {
			return strings.Trim(strings.TrimPrefix(line, "PRETTY_NAME="), "\"")
		}
	}
	return "Linux"
}

func GetRepoRoot() (string, error) {
    // If running from compiled binary in a different location, this logic might need adjustment.
    // For now, assuming we are inside the repo or providing it via flag.
    // Let's try to find the .git directory upwards.
    dir, err := os.Getwd()
    if err != nil {
        return "", err
    }
    
    for {
        if _, err := os.Stat(filepath.Join(dir, ".git")); err == nil {
            return dir, nil
        }
        parent := filepath.Dir(dir)
        if parent == dir {
            return "", fmt.Errorf("not in a git repository")
        }
        dir = parent
    }
}

func ExpandPath(path string) (string, error) {
	if strings.HasPrefix(path, "~/") || path == "~" {
		home, err := os.UserHomeDir()
		if err != nil {
			return "", err
		}
		if path == "~" {
			return home, nil
		}
		return filepath.Join(home, path[2:]), nil
	}
	return filepath.Abs(path)
}
