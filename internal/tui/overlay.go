package tui

import (
	"fmt"
	"strings"

	"github.com/charmbracelet/lipgloss"
)

// OverlayType identifies the kind of overlay.
type OverlayType int

const (
	OverlayNone OverlayType = iota
	OverlayTextInput
	OverlayConfirmation
	OverlayHelp
	OverlaySitePicker
)

// Overlay renders a centered modal on top of the main content.
type Overlay struct {
	Active     OverlayType
	Title      string
	Message    string
	InputValue string
	Width      int
	Height     int
}

// NewOverlay creates an inactive overlay.
func NewOverlay() *Overlay {
	return &Overlay{Active: OverlayNone}
}

// Show activates the overlay.
func (o *Overlay) Show(typ OverlayType, title, message string) {
	o.Active = typ
	o.Title = title
	o.Message = message
	o.InputValue = ""
}

// Hide deactivates the overlay.
func (o *Overlay) Hide() {
	o.Active = OverlayNone
	o.Title = ""
	o.Message = ""
	o.InputValue = ""
}

// IsActive returns true if an overlay is showing.
func (o *Overlay) IsActive() bool {
	return o.Active != OverlayNone
}

// SetSize updates the available screen dimensions for centering.
func (o *Overlay) SetSize(w, h int) {
	o.Width = w
	o.Height = h
}

// View renders the overlay content (without background).
func (o *Overlay) View() string {
	if !o.IsActive() {
		return ""
	}

	var content string
	switch o.Active {
	case OverlayTextInput:
		content = o.renderTextInput()
	case OverlayConfirmation:
		content = OverlayTitleStyle.Render(o.Title) + "\n\n" +
			o.Message + "\n\n" +
			MenuKeyStyle.Render("y") + " yes  " +
			MenuKeyStyle.Render("n") + " no"
	case OverlayHelp:
		content = o.renderHelp()
	}

	overlayWidth := min(60, o.Width-4)
	rendered := OverlayStyle.Width(overlayWidth).Render(content)

	return lipgloss.Place(o.Width, o.Height, lipgloss.Center, lipgloss.Center, rendered)
}

func (o *Overlay) renderTextInput() string {
	charCount := fmt.Sprintf("%d/32", len(o.InputValue))

	inputContent := o.InputValue + "█"
	inputBox := InputFieldStyle.Width(40).Render(inputContent)

	return OverlayTitleStyle.Render(o.Title) + "\n\n" +
		lipgloss.NewStyle().Foreground(ColorSecondary).Render(o.Message) + "\n\n" +
		inputBox + "  " + lipgloss.NewStyle().Foreground(ColorMuted).Render(charCount) + "\n\n" +
		MenuDescStyle.Render("Enter to confirm · Esc to cancel")
}

func (o *Overlay) renderHelp() string {
	leftCol := OverlayTitleStyle.Render("Navigation") + "\n\n" +
		helpLine("j/k ↑/↓", "Navigate instances") +
		helpLine("Tab", "Switch tab") +
		helpLine("Enter/o", "Attach to session") +
		helpLine("i", "Input mode") +
		helpLine("Esc", "Exit input mode") +
		helpLine("J/K", "Scroll diff") +
		helpLine("]/[", "Next/prev file in diff")

	rightCol := OverlayTitleStyle.Render("Actions") + "\n\n" +
		helpLine("n", "New instance") +
		helpLine("D", "Kill instance") +
		helpLine("p", "Push branch") +
		helpLine("c", "Checkout worktree") +
		helpLine("r", "Resume paused") +
		helpLine("?", "Toggle help") +
		helpLine("q", "Quit")

	left := lipgloss.NewStyle().Width(28).Render(leftCol)
	right := lipgloss.NewStyle().Width(28).Render(rightCol)

	return lipgloss.JoinHorizontal(lipgloss.Top, left, right) + "\n\n" +
		MenuDescStyle.Render("Press Esc or ? to close")
}

func helpLine(key, desc string) string {
	return "  " + MenuKeyStyle.Render(key) +
		strings.Repeat(" ", max(12-len(key), 1)) +
		lipgloss.NewStyle().Foreground(ColorSecondary).Render(desc) + "\n"
}

// DimView applies a faint effect to each line of the base view.
func DimView(base string) string {
	lines := strings.Split(base, "\n")
	for i, line := range lines {
		lines[i] = DimmedStyle.Render(line)
	}
	return strings.Join(lines, "\n")
}
