// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "my-food-app-backend",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.115.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),

        .package(url: "https://github.com/vapor/fluent.git", from: "4.13.0"),
        .package(url: "https://github.com/vapor/fluent-mongo-driver.git", from: "1.4.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.12.0"),
    ],
    targets: [
        .target(name: "Model"),
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentMongoDriver", package: "fluent-mongo-driver"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .target(name: "Model"),
            ]
        ),
        .testTarget(name: "ModelTests", dependencies: [
            .target(name: "Model"),
        ]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .target(name: "Model"),
            .product(name: "XCTVapor", package: "vapor"),

            // Workaround for https://github.com/apple/swift-package-manager/issues/6940
            .product(name: "Vapor", package: "vapor"),
        ])
    ]
)
