const std = @import("std");

const EBuilder = @import("emacs-module").Builder;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const eb = EBuilder.init(b, b.dependency("emacs-module", .{}));

    const emod = eb.addEmacsModule(.{
        .name = "example-zig-dynmod",
        .root_source_file = b.path("src/root.zig"),
        .version = std.SemanticVersion.parse("0.1.0") catch @panic("Bad parse"),
        .target = target,
        .optimize = optimize,
    });

    // TODO: vendor this into EmacsModule.install()
    // TODO: copy .el files into zig-out/emacs?
    b.getInstallStep().dependOn(&b.addInstallFile(
        emod.compile_step.getEmittedBin(),
        "emacs/example-zig-dynmod.so",
    ).step);
}
