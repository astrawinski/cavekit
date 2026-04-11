package site

import (
	"os"
	"path/filepath"
)

// SiteStatus classifies the overall status of a site.
type SiteStatus int

const (
	SiteAvailable  SiteStatus = iota // Has incomplete tasks, no active worktree
	SiteInProgress                   // Has an active worktree with Ralph Loop running
	SiteDone                         // All tasks complete
)

func (s SiteStatus) String() string {
	switch s {
	case SiteDone:
		return "done"
	case SiteInProgress:
		return "in-progress"
	default:
		return "available"
	}
}

// Icon returns a display icon for the site status.
func (s SiteStatus) Icon() string {
	switch s {
	case SiteDone:
		return "✓"
	case SiteInProgress:
		return "⟳"
	default:
		return "·"
	}
}

// ClassifySite determines the overall status of a site.
func ClassifySite(s *Site, statuses TaskStatusMap, worktreePath string) SiteStatus {
	summary := ComputeProgress(s, statuses)

	// All done?
	if summary.Done == summary.Total && summary.Total > 0 {
		return SiteDone
	}

	// Check for active Cavekit loop state in worktree
	if worktreePath != "" {
		if _, err := os.Stat(filepath.Join(worktreePath, ".cavekit", "loop-state.local.md")); err == nil {
			return SiteInProgress
		}
		if _, err := os.Stat(filepath.Join(worktreePath, ".claude", "ralph-loop.local.md")); err == nil {
			return SiteInProgress
		}
	}

	return SiteAvailable
}
