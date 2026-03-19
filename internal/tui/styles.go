package tui

import "github.com/charmbracelet/lipgloss"

// Layout proportions
const (
	LeftPanelRatio  = 0.30
	RightPanelRatio = 0.70
	MinLeftWidth    = 25
	MenuHeight      = 3 // status line + gap + menu
)

// Colors
var (
	ColorPrimary   = lipgloss.Color("#7C3AED") // purple
	ColorSecondary = lipgloss.Color("#6B7280") // gray
	ColorSuccess   = lipgloss.Color("#10B981") // green
	ColorWarning   = lipgloss.Color("#F59E0B") // yellow
	ColorDanger    = lipgloss.Color("#EF4444") // red
	ColorMuted     = lipgloss.Color("#4B5563") // dark gray
	ColorBorder    = lipgloss.Color("#374151") // border gray
	ColorHighlight = lipgloss.Color("#1F2937") // subtle bg
	ColorDimBg     = lipgloss.Color("#111827") // dim background
)

// Panel styles
var (
	LeftPanelStyle = lipgloss.NewStyle().
			BorderStyle(lipgloss.RoundedBorder()).
			BorderForeground(ColorBorder)

	RightPanelStyle = lipgloss.NewStyle().
			BorderStyle(lipgloss.RoundedBorder()).
			BorderForeground(ColorBorder)

	SelectedItemStyle = lipgloss.NewStyle().
				Background(ColorHighlight).
				Bold(true)

	NormalItemStyle = lipgloss.NewStyle()
)

// Header styles
var (
	HeaderStyle = lipgloss.NewStyle().
			Background(lipgloss.Color("#1E1B2E")).
			Padding(0, 1)

	HeaderTitleStyle = lipgloss.NewStyle().
				Bold(true).
				Foreground(ColorPrimary)

	HeaderProjectStyle = lipgloss.NewStyle().
				Foreground(ColorSecondary)

	HeaderStatsStyle = lipgloss.NewStyle().
				Foreground(ColorMuted)
)

// Status line styles
var (
	StatusLineStyle = lipgloss.NewStyle().
			Background(lipgloss.Color("#1A1A2E")).
			Foreground(ColorSecondary).
			Padding(0, 0)
)

// Tab styles
var (
	ActiveTabStyle = lipgloss.NewStyle().
			Bold(true).
			Foreground(ColorPrimary).
			BorderStyle(lipgloss.NormalBorder()).
			BorderBottom(true).
			BorderForeground(ColorPrimary).
			Padding(0, 1)

	InactiveTabStyle = lipgloss.NewStyle().
				Foreground(ColorSecondary).
				Padding(0, 1)

	TabSepStyle = lipgloss.NewStyle().
			Foreground(ColorBorder)

	TabBarStyle = lipgloss.NewStyle().
			BorderStyle(lipgloss.NormalBorder()).
			BorderBottom(true).
			BorderForeground(ColorBorder)

	TabBadgeStyle = lipgloss.NewStyle().
			Foreground(ColorMuted)
)

// Status indicators
var (
	StatusRunning = lipgloss.NewStyle().Foreground(ColorSuccess).SetString("●")
	StatusReady   = lipgloss.NewStyle().Foreground(ColorWarning).SetString("●")
	StatusLoading = lipgloss.NewStyle().Foreground(ColorSecondary).SetString("◌")
	StatusPaused  = lipgloss.NewStyle().Foreground(ColorMuted).SetString("⏸")
	StatusDone    = lipgloss.NewStyle().Foreground(ColorSuccess).SetString("✓")
)

// Menu styles
var (
	MenuStyle = lipgloss.NewStyle().
			Foreground(ColorSecondary)

	MenuKeyStyle = lipgloss.NewStyle().
			Bold(true).
			Foreground(lipgloss.Color("#E5E7EB"))

	MenuDescStyle = lipgloss.NewStyle().
			Foreground(ColorMuted)
)

// Overlay styles
var (
	OverlayStyle = lipgloss.NewStyle().
			Border(lipgloss.RoundedBorder()).
			BorderForeground(ColorPrimary).
			Padding(1, 2)

	OverlayTitleStyle = lipgloss.NewStyle().
				Bold(true).
				Foreground(ColorPrimary)

	DimmedStyle = lipgloss.NewStyle().
			Faint(true)

	InputFieldStyle = lipgloss.NewStyle().
			Border(lipgloss.RoundedBorder()).
			BorderForeground(ColorBorder).
			Padding(0, 1)
)

// Diff styles
var (
	DiffAddStyle    = lipgloss.NewStyle().Foreground(ColorSuccess)
	DiffRemoveStyle = lipgloss.NewStyle().Foreground(ColorDanger)
	DiffHeaderStyle = lipgloss.NewStyle().Bold(true).Foreground(ColorPrimary)

	DiffLineNumberStyle  = lipgloss.NewStyle().Foreground(ColorMuted)
	DiffFileSectionStyle = lipgloss.NewStyle().Bold(true).Foreground(ColorWarning).
				BorderStyle(lipgloss.NormalBorder()).
				BorderBottom(true).
				BorderForeground(ColorBorder)
)

// Progress bar styles
var (
	ProgressBarFullStyle = lipgloss.NewStyle().
				Foreground(ColorSuccess)

	ProgressBarEmptyStyle = lipgloss.NewStyle().
				Foreground(ColorMuted)
)

// Scroll indicators
var (
	ScrollIndicatorStyle = lipgloss.NewStyle().
				Foreground(ColorMuted).
				Align(lipgloss.Center)
)

// Instance list styles
var (
	InstanceSelectedBorder = lipgloss.NewStyle().
				Foreground(ColorPrimary).
				SetString("▎")

	InstanceNormalBorder = lipgloss.NewStyle().
				SetString(" ")
)

// Toast styles
var (
	ToastSuccessStyle = lipgloss.NewStyle().
				Background(lipgloss.Color("#065F46")).
				Foreground(lipgloss.Color("#D1FAE5")).
				Padding(0, 2).
				Bold(true)

	ToastErrorStyle = lipgloss.NewStyle().
			Background(lipgloss.Color("#7F1D1D")).
			Foreground(lipgloss.Color("#FEE2E2")).
			Padding(0, 2).
			Bold(true)

	ToastInfoStyle = lipgloss.NewStyle().
			Background(lipgloss.Color("#1E3A5F")).
			Foreground(lipgloss.Color("#DBEAFE")).
			Padding(0, 2).
			Bold(true)
)

// Dashboard styles
var (
	DashboardTitleStyle = lipgloss.NewStyle().
				Bold(true).
				Foreground(ColorPrimary)

	DashboardHintStyle = lipgloss.NewStyle().
				Foreground(ColorMuted)
)
