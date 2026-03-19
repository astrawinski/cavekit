package tui

import (
	"strings"

	"github.com/charmbracelet/lipgloss"
)

// TabContent renders the right panel with tabbed content.
type TabContent struct {
	activeTab Tab
	width     int
	height    int

	// Content for each tab
	previewContent  string
	diffContent     string
	terminalContent string

	// Badge data
	diffStats string
}

// NewTabContent creates a new tabbed content component.
func NewTabContent() *TabContent {
	return &TabContent{
		activeTab: TabPreview,
	}
}

// SetActiveTab sets the currently visible tab.
func (t *TabContent) SetActiveTab(tab Tab) {
	t.activeTab = tab
}

// SetSize updates available dimensions.
func (t *TabContent) SetSize(w, h int) {
	t.width = w
	t.height = h
}

// SetPreview sets the preview tab content.
func (t *TabContent) SetPreview(content string) {
	t.previewContent = content
}

// SetDiff sets the diff tab content.
func (t *TabContent) SetDiff(content string) {
	t.diffContent = content
}

// SetTerminal sets the terminal tab content.
func (t *TabContent) SetTerminal(content string) {
	t.terminalContent = content
}

// SetDiffStats sets the diff badge text (e.g. "+45/-12").
func (t *TabContent) SetDiffStats(stats string) {
	t.diffStats = stats
}

// View renders the tabbed content panel.
func (t *TabContent) View() string {
	tabBar := t.renderTabBar()

	var content string
	switch t.activeTab {
	case TabPreview:
		content = t.previewContent
		if content == "" {
			content = t.renderEmpty("Select an instance to preview")
		}
	case TabDiff:
		content = t.diffContent
		if content == "" {
			content = t.renderEmpty("No changes yet")
		}
	case TabTerminal:
		content = t.terminalContent
		if content == "" {
			content = t.renderEmpty("Press Enter to open a shell")
		}
	}

	// Truncate content to fit
	lines := strings.Split(content, "\n")
	maxLines := t.height - 2 // account for tab bar
	if maxLines > 0 && len(lines) > maxLines {
		lines = lines[:maxLines]
	}

	return tabBar + "\n" + strings.Join(lines, "\n")
}

func (t *TabContent) renderEmpty(msg string) string {
	styled := lipgloss.NewStyle().Foreground(ColorMuted).Render(msg)
	contentH := max(t.height-3, 1)
	return lipgloss.Place(t.width, contentH, lipgloss.Center, lipgloss.Center, styled)
}

func (t *TabContent) renderTabBar() string {
	var tabs []string
	sep := TabSepStyle.Render(" │ ")

	for i, tab := range []Tab{TabPreview, TabDiff, TabTerminal} {
		if i > 0 {
			tabs = append(tabs, sep)
		}

		label := tab.String()
		// Add badge to Diff tab
		if tab == TabDiff && t.diffStats != "" {
			label += " " + TabBadgeStyle.Render("("+t.diffStats+")")
		}

		if tab == t.activeTab {
			tabs = append(tabs, ActiveTabStyle.Render(label))
		} else {
			tabs = append(tabs, InactiveTabStyle.Render(label))
		}
	}
	return lipgloss.JoinHorizontal(lipgloss.Top, tabs...)
}
