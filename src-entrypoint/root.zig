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
    else // FIXME: extremely terrible error
        @compileError("root.module_options.gpl_compatible must be true");
}
