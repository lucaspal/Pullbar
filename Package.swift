// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PRInbox",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "PRInbox",
            path: "Sources/PRInbox",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("Security"),
                .linkedFramework("ServiceManagement"),
            ]
        ),
    ]
)
