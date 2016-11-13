import PackageDescription

let package = Package(
    name: "Capnpc",
    targets: [
        Target(name: "Runtime"),
        Target(name: "Generator", dependencies: ["Runtime"]),
    ]
)
