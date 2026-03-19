// Package site handles site file discovery, parsing, and task tracking.
package site

import (
	"os"
	"path/filepath"
	"regexp"
	"strings"
)

// DeriveName applies the canonical name derivation from a site filename.
// Mirrors the bash sed chain: strip prefixes (plan-, build-site-, feature-),
// strip -?frontier-? or -?site-?, strip leading/trailing hyphens. Empty → "execute".
func DeriveName(filename string) string {
	// Strip extension
	name := strings.TrimSuffix(filename, filepath.Ext(filename))

	// Strip known prefixes
	for _, prefix := range []string{"plan-", "build-site-", "feature-"} {
		name = strings.TrimPrefix(name, prefix)
	}

	// Strip frontier or site with optional surrounding hyphens
	reFrontier := regexp.MustCompile(`-?frontier-?`)
	name = reFrontier.ReplaceAllString(name, "")
	reSite := regexp.MustCompile(`-?site-?`)
	name = reSite.ReplaceAllString(name, "")

	// Strip leading/trailing hyphens
	name = strings.Trim(name, "-")

	if name == "" {
		return "execute"
	}
	return name
}

// SiteFile represents a discovered site file.
type SiteFile struct {
	Path string // Full path to the file
	Name string // Derived name (used for worktree/branch naming)
}

// Discover scans context/sites/ (or context/frontiers/) for site markdown files.
// Excludes archive/ subdirectory.
func Discover(projectRoot string) ([]SiteFile, error) {
	var results []SiteFile

	// Try both directory names (sites is the newer convention, frontiers is legacy)
	for _, dir := range []string{"context/sites", "context/frontiers"} {
		siteDir := filepath.Join(projectRoot, dir)
		entries, err := os.ReadDir(siteDir)
		if err != nil {
			if os.IsNotExist(err) {
				continue
			}
			return nil, err
		}

		for _, entry := range entries {
			if entry.IsDir() {
				continue // skip archive/ and other subdirs
			}
			name := entry.Name()
			if !strings.HasSuffix(name, ".md") {
				continue
			}
			// File must contain "frontier" or "site" in the name (broad match)
			lowerName := strings.ToLower(name)
			if !strings.Contains(lowerName, "frontier") && !strings.Contains(lowerName, "site") {
				continue
			}

			results = append(results, SiteFile{
				Path: filepath.Join(siteDir, name),
				Name: DeriveName(name),
			})
		}
	}

	return results, nil
}
