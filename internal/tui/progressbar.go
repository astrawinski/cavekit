package tui

import "strings"

// RenderProgressBar renders an ASCII progress bar of the given width.
func RenderProgressBar(done, total, width int) string {
	if width <= 0 || total <= 0 {
		return strings.Repeat("░", max(width, 0))
	}

	filled := (done * width) / total
	if filled > width {
		filled = width
	}

	return ProgressBarFullStyle.Render(strings.Repeat("█", filled)) +
		ProgressBarEmptyStyle.Render(strings.Repeat("░", width-filled))
}
