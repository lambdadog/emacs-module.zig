const std = @import("std");
const Build = std.Build;
const Module = Build.Module;

const EmacsModule = @This();

module: *Module,
compile_step: *Build.Step.Compile,
artifact_name: []const u8,

pub const Options = struct {
    name: []const u8,

    root_source_file: Build.LazyPath,
    version: ?std.SemanticVersion = null,

    target: Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    code_model: std.builtin.CodeModel = .default,

    // Unsure if all of these are useful for an emacs dynmod...
    max_rss: usize = 0,
    link_libc: ?bool = null,
    single_threaded: ?bool = null,
    pic: ?bool = null,
    strip: ?bool = null,
    unwind_tables: ?bool = null,
    omit_frame_pointer: ?bool = null,
    sanitize_thread: ?bool = null,
    error_tracing: ?bool = null,
    use_llvm: ?bool = null,
    use_lld: ?bool = null,
    zig_lib_dir: ?Build.LazyPath = null,
    win32_manifest: ?Build.LazyPath = null,
};

pub fn create(
    owner: *Build,
    dep: *Build.Dependency,
    options: Options,
) *EmacsModule {
    // We don't strictly need to dynamically allocate this, but the
    // performance hit of the double dereference doesn't really matter
    // while building the build graph, and it's completely cut out of
    // the equation when actually building, so I'm happy to do so just
    // in order to make the interface consistent between it and the
    // std build steps.
    const emod = owner.allocator.create(EmacsModule) catch @panic("OOM");

    const lib_module = dep.module("emacs-module");

    emod.module = Module.create(owner, .{
        .root_source_file = options.root_source_file,
    });

    emod.module.addImport("emacs-module", lib_module);

    emod.compile_step = Build.Step.Compile.create(owner, .{
        .name = options.name,
        .root_module = .{
            .root_source_file = dep.path("src-entrypoint/root.zig"),

            .target = options.target,
            .optimize = options.optimize,
            .code_model = options.code_model,

            .link_libc = options.link_libc,
            .single_threaded = options.single_threaded,
            .pic = options.pic,
            .strip = options.strip,
            .unwind_tables = options.unwind_tables,
            .omit_frame_pointer = options.omit_frame_pointer,
            .sanitize_thread = options.sanitize_thread,
            .error_tracing = options.error_tracing,
        },
        .kind = .lib,
        .linkage = .dynamic,
        .version = options.version,
        .max_rss = options.max_rss,
        .use_llvm = options.use_llvm,
        .use_lld = options.use_lld,
        .zig_lib_dir = options.zig_lib_dir orelse owner.zig_lib_dir,
        .win32_manifest = options.win32_manifest,
    });

    emod.compile_step.root_module.addImport("emacs-module", lib_module);
    emod.compile_step.root_module.addImport("emod-root", emod.module);

    emod.artifact_name = std.fmt.allocPrint(
        owner.allocator,
        "{s}.{s}",
        .{
            options.name,
            switch (options.target.result.ofmt) {
                .coff => "dll",
                .elf => "so",
                .macho => "dylib",
                else => @panic("Unsupported object format"),
            },
        },
    ) catch @panic("OOM");

    return emod;
}

// TODO: copy .el files into zig-out/emacs?
// FIXME: hack, overly dependent on build system internals
pub fn install(self: *EmacsModule) void {
    const b = self.module.owner;

    const install_path = std.fmt.allocPrint(
        b.allocator,
        "emacs/{s}",
        .{self.artifact_name},
    ) catch @panic("OOM");

    b.getInstallStep().dependOn(&b.addInstallFile(
        self.compile_step.getEmittedBin(),
        install_path,
    ).step);
}
