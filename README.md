# PR Inbox — a menu bar mirror of github.com/pulls/inbox

A small native macOS menu bar app. It shows the number of pull requests that
wait for your review next to the clock, and its menu has the same sections as
the GitHub PR inbox page, so you never have to navigate there to know what is
waiting on you:

- **Needs your review** — you were asked directly (`user-review-requested:@me`)
- **Needs your teams' review** — a team you belong to was asked, but not you
  (`review-requested:@me` minus the section above)
- **Your drafts** — your open draft PRs
- **Waiting for review or checks** — your open PRs that are neither blocked nor ready
- **Needs action** — your PRs with *changes requested*, failing checks or a merge conflict
- **Ready to merge** — your PRs that are approved, green and mergeable

Each PR row shows repository and number, author, when it was last updated, the
review status (Awaiting approval, Changes requested, Approved, Not ready), the
check count (`✓ 186/186`, `✕ 184/186`, `● pending`) and the comment count.
Clicking a row opens the PR in your browser.

The menu bar title reads `5` (needs your review), `5+1` (plus one team request)
and adds `⚠︎1` when one of your own PRs needs action. Hovering shows all six counts.

## Requirements

- macOS 13 Ventura or newer
- Xcode Command Line Tools (`xcode-select --install`) — they include `swift`
- A GitHub token (see below)

No third-party dependencies: AppKit, Foundation, Security and ServiceManagement only.

## Build and run

```sh
cd tools/pr-inbox-menubar
make install        # builds "PR Inbox.app", copies it to ~/Applications and opens it
```

Other targets:

| Command | What it does |
|---|---|
| `make run` | Runs directly from the package, no bundle, handy while hacking |
| `make app` | Builds `build/PR Inbox.app` (ad-hoc signed) without installing |
| `make clean` | Removes build output |

The app is ad-hoc signed, so macOS may ask once whether to open it. It stores
nothing outside your Keychain and `~/Library/Preferences`.

## GitHub token

On first launch the app looks for a token in this order:

1. The **login Keychain** (item "PR Inbox (GitHub)") — where it saves the token you enter.
2. A logged-in **GitHub CLI**: if `gh auth token` prints a token, that is used for
   the session and nothing is saved.
3. A **prompt** where you paste a token, which is then saved to the Keychain.

Token types:

- Classic personal access token with the `repo` and `read:org` scopes. `read:org`
  is what lets the search resolve team review requests.
- Fine-grained token with **Pull requests: Read** for the repositories you care
  about, granted for the `semdatex` organisation.

Use **Set GitHub token…** in the menu to replace it at any time.

## Settings (all in the menu)

- **Updated** — mirrors the site's "Updated: Last month" filter. Default is last
  month; choose last week, last 3 months or any time.
- **Refresh every** — 1, 2 (default), 5 or 15 minutes. Opening the menu also
  triggers a refresh.
- **Launch at login** — registers the app with the system login items
  (only when running the packaged `.app`).

## How it works

`InboxService` runs three GitHub GraphQL searches concurrently
(`review-requested:@me`, `user-review-requested:@me`, `author:@me`, each with
`is:pr is:open archived:false` and the updated window) and `Inbox.build` folds
them into the six sections. Check counts come from `statusCheckRollup`; when a
PR has more than 100 checks the remaining pages are fetched, so the counts match
what GitHub shows even for the 180+ check pipelines in this monorepo.

Files:

| File | Role |
|---|---|
| `Sources/PRInbox/PRInboxApp.swift` | `@main` entry point |
| `Sources/PRInbox/AppDelegate.swift` | Status item, menu, refresh timer, actions |
| `Sources/PRInbox/GitHubClient.swift` | GraphQL client and wire types |
| `Sources/PRInbox/InboxService.swift` | The three searches → `Inbox` |
| `Sources/PRInbox/Models.swift` | `PullRequest`, `Checks`, sections and classification |
| `Sources/PRInbox/TokenProvider.swift` | Keychain → `gh` → prompt |
| `Sources/PRInbox/Keychain.swift` | Generic-password storage |
| `Sources/PRInbox/Settings.swift` | UserDefaults-backed settings |
| `Packaging/Info.plist` | Bundle metadata, `LSUIElement` (no Dock icon) |
| `Makefile` | build / run / app / install |
