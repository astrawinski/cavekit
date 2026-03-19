package tui

import (
	"github.com/charmbracelet/lipgloss"
)

// ToastType represents the kind of toast notification.
type ToastType int

const (
	ToastSuccess ToastType = iota
	ToastError
	ToastInfo
)

// Toast is a single notification.
type Toast struct {
	message   string
	toastType ToastType
	ticksLeft int
}

// ToastManager manages a queue of toast notifications.
type ToastManager struct {
	active *Toast
	width  int
	height int
}

// NewToastManager creates a toast manager.
func NewToastManager() *ToastManager {
	return &ToastManager{}
}

// Add queues a new toast. Replaces any active toast.
func (t *ToastManager) Add(message string, toastType ToastType) {
	t.active = &Toast{
		message:   message,
		toastType: toastType,
		ticksLeft: 6, // 3 seconds at 500ms ticks
	}
}

// Tick decrements the active toast timer.
func (t *ToastManager) Tick() {
	if t.active != nil {
		t.active.ticksLeft--
		if t.active.ticksLeft <= 0 {
			t.active = nil
		}
	}
}

// SetSize updates the screen dimensions for positioning.
func (t *ToastManager) SetSize(w, h int) {
	t.width = w
	t.height = h
}

// IsActive returns true if a toast is showing.
func (t *ToastManager) IsActive() bool {
	return t.active != nil
}

// View renders the active toast, or empty string if none.
func (t *ToastManager) View() string {
	if t.active == nil {
		return ""
	}

	msg := t.active.message
	if len(msg) > 40 {
		msg = msg[:37] + "..."
	}

	var style lipgloss.Style
	switch t.active.toastType {
	case ToastSuccess:
		style = ToastSuccessStyle
	case ToastError:
		style = ToastErrorStyle
	case ToastInfo:
		style = ToastInfoStyle
	}

	return style.Render(msg)
}

// Overlay renders the toast positioned in the bottom-right of the given base view.
func (t *ToastManager) Overlay(base string, width, height int) string {
	if t.active == nil {
		return base
	}

	toast := t.View()
	return lipgloss.Place(width, height, lipgloss.Right, lipgloss.Bottom, toast,
		lipgloss.WithWhitespaceChars(" "),
		lipgloss.WithWhitespaceForeground(lipgloss.NoColor{}),
	)
}
