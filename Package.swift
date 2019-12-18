// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "SDL",
    products: [
        .library(
            name: "SDL",
            targets: ["SDL"]),
        ],
    targets: [
        .target(
            name: "SDL",
            dependencies: ["CSDL2", "CSDL2TTF", "CSDL2Image"]),
        .systemLibrary(
            name: "CSDL2",
            pkgConfig: "sdl2",
            providers: [
                .brew(["sdl2"]),
                .apt(["libsdl2-dev"])
            ]),
        .systemLibrary(
            name: "CSDL2TTF",
            pkgConfig: "sdl2_ttf",
            providers: [
                .brew(["sdl2_ttf"]),
                .apt(["libsdl2-ttf-dev"])
            ]),
		.systemLibrary(
			name: "CSDL2Image",
			pkgConfig: "sdl2_image",
			providers: [
				.brew(["sdl2_image"]),
				.apt(["libsdl2-image-dev"])
			]),
        ],
    swiftLanguageVersions: [.v5]
)
