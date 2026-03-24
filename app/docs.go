package app

import (
	"embed"
	"io/fs"
	"net/http"
)

//go:generate moat build ../docs ./docs-site

//go:embed all:docs-site
var docsSiteFS embed.FS

// NewDocsHandler returns an http.Handler that serves the moat-generated
// static documentation site from the embedded filesystem.
func NewDocsHandler() http.Handler {
	sub, _ := fs.Sub(docsSiteFS, "docs-site")
	return http.FileServer(http.FS(sub))
}
