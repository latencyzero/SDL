// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "SDL",
    products: [
        .library(
            name: "SDL",
            targets: ["SDL"]),
//        .executable(
//            name: "SDLDemo",
//            targets: ["SDLDemo"]),
        ],
    targets: [
//        .target(
//            name: "SDLDemo",
//            dependencies: ["SDL"]),
        .target(
            name: "SDL",
            dependencies: ["CSDL2", "CSDL2TTF"]),
        .systemLibrary(
            name: "CSDL2",
            pkgConfig: "sdl2",
            providers: [
                .brew(["sdl2"]),
                .apt(["libSDL2-dev"])
            ]),
        .systemLibrary(
            name: "CSDL2TTF",
            pkgConfig: "sdl2_ttf",
            providers: [
                .brew(["sdl2_ttf"]),
                .apt(["libSDL2-ttf-dev"])
            ]),
//        .testTarget(
//            name: "SDLTests",
//            dependencies: ["SDL"]),
        ],
    swiftLanguageVersions: [.v5]
)
