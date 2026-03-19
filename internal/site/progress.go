package site

import "fmt"

// ProgressString generates a compact progress display for a site.
// Format: {icon} {name} {done}/{total} (e.g., "⟳ auth 3/12")
// Includes current task ID if in-progress.
func ProgressString(name string, status SiteStatus, summary ProgressSummary, currentTaskID string) string {
	base := fmt.Sprintf("%s %s %d/%d", status.Icon(), name, summary.Done, summary.Total)
	if status == SiteInProgress && currentTaskID != "" {
		base += " [" + currentTaskID + "]"
	}
	return base
}
