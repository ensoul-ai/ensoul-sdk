// swift-tools-version: 5.9
import PackageDescription
let package = Package(
    name: "Ensoul",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [.library(name: "Ensoul", targets: ["Ensoul"])],
    targets: [
        .target(name: "Ensoul", path: "swift/Sources/Ensoul"),
        .testTarget(name: "EnsoulTests", dependencies: ["Ensoul"], path: "swift/Tests/EnsoulTests"),
    ]
)
