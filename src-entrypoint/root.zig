const emod = @import("emacs-module");
const eroot = @import("emod-root");

const options: emod.Options = if (@hasDecl(eroot, "module_options"))
    eroot.module_options
else
    .{};

usingnamespace if (@hasDecl(eroot, "std_options")) struct {
    pub const std_options = eroot.std_options;
} else struct {};

usingnamespace if (@hasDecl(eroot, "os")) struct {
    pub const os = eroot.os;
} else struct {};

var gpl_token: c_int = undefined;
comptime {
    if (options.gpl_compatible)
        @export(gpl_token, .{ .name = "plugin_is_GPL_compatible" })
    else // zig fmt: off
        @compileError("Emacs refuses to load dynamic modules that don't specially signal that they are GPL-compatible.\n\r"
          ++ "\n\r"
          ++ "With emacs-module.zig, this is done by adding the following to the top level of whatever file is your root_source_file (usually, src/root.zig or src/main.zig, check build.zig if you aren't sure):\n\r"
          ++ "\n\r"
          ++ "  pub const module_options = .{\n\r"
          ++ "    .gpl_compatible = true,\n\r"
          ++ "  };\n\r"
        );
    // zig fmt: on
}
