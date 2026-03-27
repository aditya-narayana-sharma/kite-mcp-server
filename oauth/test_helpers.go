//go:build testing

// This file is only compiled with -tags=testing.
// Used by integration tests in other packages.

package oauth

// GenerateTestToken creates a JWT token for testing purposes.
func (s *Server) GenerateTestToken(kiteUserID, sessionID string) (string, error) {
	return s.generateAccessToken(kiteUserID, sessionID)
}
