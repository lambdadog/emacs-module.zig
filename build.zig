const std = @import("std");
const Build = std.Build;

pub const Builder = struct {
    pub const Step = struct {
        pub const EmacsModule = @import("src-build/Step/EmacsModule.zig");
    };

    owner: *Build,
    dep: *Build.Dependency,

    pub fn init(owner: *Build, dep: *Build.Dependency) Builder {
        return .{
            .owner = owner,
            .dep = dep,
        };
    }

    pub fn addEmacsModule(
        self: Builder,
        options: Step.EmacsModule.Options,
    ) *Step.EmacsModule {
        return Step.EmacsModule.create(self.owner, self.dep, options);
    }
};

pub fn build(b: *std.Build) void {
    _ = b.addModule("emacs-module", .{
        .root_source_file = b.path("src-lib/root.zig"),
    });
}
