import Foundation

/// Runs the three searches that github.com/pulls/inbox is made of and folds
/// them into sections.
struct InboxService {
    let client: GitHubClient

    func fetch(window: UpdatedWindow) async throws -> Inbox {
        let base = ["is:open", "archived:false", "sort:updated-desc", window.searchQualifier]
            .compactMap { $0 }
            .joined(separator: " ")

        async let requested = client.searchPullRequests("\(base) review-requested:@me")
        async let direct = client.searchPullRequests("\(base) user-review-requested:@me")
        async let authored = client.searchPullRequests("\(base) author:@me")

        let (r, d, a) = try await (requested, direct, authored)
        return Inbox.build(
            reviewRequested: r.pullRequests,
            userReviewRequested: d.pullRequests,
            authored: a.pullRequests,
            viewerLogin: a.viewerLogin
        )
    }
}
