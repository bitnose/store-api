// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "StoreAPI",
    products: [
        .library(name: "StoreAPI", targets: ["App"]),
    ],
    dependencies: [
        // A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // Authentication package
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0"),
        
        // Swift ORM (queries, models, relations, etc) built on PostgreSQL.
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0-rc"),
        
        // VaporExt – this helps us with storing environmental variables
        .package(url: "https://github.com/vapor-community/vapor-ext.git", from: "0.1.0"),
            
        // LoggerAPI - To prevent to avoid a logging conflict
        .package(url: "https://github.com/IBM-Swift/LoggerAPI.git", .upToNextMinor(from: "1.8.0")),
        
        // Swift-SMTP for sending emails
        .package(url: "https://github.com/IBM-Swift/Swift-SMTP", .upToNextMinor(from: "5.1.0"))
        
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentPostgreSQL", "Authentication", "Vapor", "VaporExt", "SwiftSMTP", "LoggerAPI"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

