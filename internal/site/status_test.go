package site

import (
	"os"
	"path/filepath"
	"testing"
)

func TestClassifySite_Done(t *testing.T) {
	s := &Site{
		Tasks: []Task{{ID: "T-001"}, {ID: "T-002"}},
	}
	statuses := TaskStatusMap{
		"T-001": TaskDone,
		"T-002": TaskDone,
	}

	status := ClassifySite(s, statuses, "")
	if status != SiteDone {
		t.Errorf("should be Done, got %v", status)
	}
}

func TestClassifySite_InProgress(t *testing.T) {
	tmp := t.TempDir()
	os.MkdirAll(filepath.Join(tmp, ".claude"), 0755)
	os.WriteFile(filepath.Join(tmp, ".claude", "ralph-loop.local.md"), []byte("active"), 0644)

	s := &Site{
		Tasks: []Task{{ID: "T-001"}, {ID: "T-002"}},
	}
	statuses := TaskStatusMap{
		"T-001": TaskDone,
	}

	status := ClassifySite(s, statuses, tmp)
	if status != SiteInProgress {
		t.Errorf("should be InProgress, got %v", status)
	}
}

func TestClassifySite_Available(t *testing.T) {
	s := &Site{
		Tasks: []Task{{ID: "T-001"}, {ID: "T-002"}},
	}
	statuses := TaskStatusMap{
		"T-001": TaskDone,
	}

	status := ClassifySite(s, statuses, "")
	if status != SiteAvailable {
		t.Errorf("should be Available, got %v", status)
	}
}

func TestSiteStatus_String(t *testing.T) {
	if SiteDone.String() != "done" {
		t.Errorf("SiteDone.String() = %q", SiteDone.String())
	}
	if SiteInProgress.String() != "in-progress" {
		t.Errorf("SiteInProgress.String() = %q", SiteInProgress.String())
	}
	if SiteAvailable.String() != "available" {
		t.Errorf("SiteAvailable.String() = %q", SiteAvailable.String())
	}
}

func TestSiteStatus_Icon(t *testing.T) {
	if SiteDone.Icon() != "✓" {
		t.Errorf("SiteDone.Icon() = %q", SiteDone.Icon())
	}
	if SiteInProgress.Icon() != "⟳" {
		t.Errorf("SiteInProgress.Icon() = %q", SiteInProgress.Icon())
	}
	if SiteAvailable.Icon() != "·" {
		t.Errorf("SiteAvailable.Icon() = %q", SiteAvailable.Icon())
	}
}
