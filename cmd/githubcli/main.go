package main

import (
	"context"
	"flag"
	"net/http"
	"os"
	"strings"

	"github.com/google/go-github/github"
	"golang.org/x/oauth2"
)

const (
	envGithubUser = "GITHUB_USERNAME"
	envGithubPAT  = "GITHUB_PAT"
	debug         = false
	panicErrors   = false
)

const (
	sectionRepo = "repo"

	commRepoRenameIfExists = "renameIfExists"
	commRepoCreate         = "create"
	commRepoTransfer       = "transfer"
)

var (
	fDebug = flag.Bool("debug", false, "output debug-level information")
)

type logger struct {
	underlying http.RoundTripper
}

func (l logger) RoundTrip(req *http.Request) (*http.Response, error) {
	infof("making request: %v\n", req)
	return l.underlying.RoundTrip(req)
}

func main() {
	// repo create (org/)name
	// repo renameIfExists (org/)from to
	// repo transfer (orgfrom/)name nameOrOrg

	flag.Parse()

	pat, ok := os.LookupEnv(envGithubPAT)
	if !ok {
		fatalf("missing environment variable %v", envGithubPAT)
	}

	user, ok := os.LookupEnv(envGithubUser)
	if !ok {
		fatalf("missing environment variable %v", envGithubUser)
	}

	ctx := context.Background()
	ts := oauth2.StaticTokenSource(
		&oauth2.Token{AccessToken: pat},
	)
	tc := oauth2.NewClient(ctx, ts)

	if debug || *fDebug {
		tc.Transport = logger{underlying: tc.Transport}
	}

	args := flag.Args()

	if len(args) == 0 {
		fatalf("need a category")
	}

	switch args[0] {
	case sectionRepo:
	default:
		fatalf("unknown section %v", args[0])
	}

	args = args[1:]

	if len(args) == 0 {
		fatalf("need a command")
	}

	client := github.NewClient(tc)
	ctxt := context.Background()

	// TODO actually write this properly
	switch args[0] {
	case commRepoRenameIfExists:
		args := args[1:]
		if v := len(args); v != 2 {
			fatalf("expected 2 arguments for %v; got %v", commRepoRenameIfExists, v)
		}

		fromParts := strings.Split(args[0], "/")
		to := &github.Repository{
			Name: &args[1],
		}

		orgOrUser := user
		if len(fromParts) == 2 {
			orgOrUser = fromParts[0]
		}
		from := fromParts[len(fromParts)-1]

		_, resp, err := client.Repositories.Edit(ctxt, orgOrUser, from, to)
		if err != nil {
			if resp == nil || resp.StatusCode != http.StatusNotFound {
				fatalf("failed to %v: %v", commRepoRenameIfExists, err)
			}
		}

	case commRepoCreate:
		args := args[1:]
		if v := len(args); v != 1 {
			fatalf("expected 1 argument for %v; got %v", commRepoCreate, v)
		}

		nameParts := strings.Split(args[0], "/")

		r := &github.Repository{
			Name: &nameParts[len(nameParts)-1],
		}

		// when creating a repo, we set userOrOrg to "" to indicate a
		// user repo
		userOrOrg := ""

		if len(nameParts) == 2 && nameParts[0] != user {
			userOrOrg = nameParts[0]
		}

		_, _, err := client.Repositories.Create(ctxt, userOrOrg, r)
		if err != nil {
			fatalf("failed to %v: %v", commRepoCreate, err)
		}

	case commRepoTransfer:
		args := args[1:]

		if v := len(args); v != 2 {
			fatalf("expected 2 arguments for %v; got %v", commRepoTransfer, v)
		}

		fromParts := strings.Split(args[0], "/")
		tr := github.TransferRequest{
			NewOwner: args[1],
		}

		orgOrUser := user
		if len(fromParts) == 2 {
			orgOrUser = fromParts[0]
		}
		from := fromParts[len(fromParts)-1]

		_, resp, err := client.Repositories.Transfer(ctxt, orgOrUser, from, tr)
		if err != nil && (resp == nil || resp.StatusCode != http.StatusAccepted) {
			if resp == nil || resp.StatusCode != http.StatusNotFound {
				fatalf("failed to %v: %v", commRepoTransfer, err)
			}
		}

	default:
		fatalf("unknown command %v", args[0])
	}

}
