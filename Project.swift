import ProjectDescription

let project = Project(
    name: "Whitney Art Explorer",
    targets: [
        .target(
            name: "Whitney Art Explorer",
            destinations: .iOS,
            product: .app,
            bundleId: "dev.tuist.Whitney-Art-Explorer",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            buildableFolders: [
                "Whitney Art Explorer/Sources",
                "Whitney Art Explorer/Resources",
            ],
            dependencies: []
        ),
        .target(
            name: "Whitney Art ExplorerTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "dev.tuist.Whitney-Art-ExplorerTests",
            infoPlist: .default,
            buildableFolders: [
                "Whitney Art Explorer/Tests"
            ],
            dependencies: [.target(name: "Whitney Art Explorer")]
        ),
    ]
)
