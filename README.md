# emacs-module.zig

Library for writing Emacs [dynamic modules](https://www.gnu.org/software/emacs/manual/html_node/elisp/Writing-Dynamic-Modules.html) in Zig.

## FAQ
### What is this "module_options" thing about and why is it stopping me from compiling?
Short answer: Add this to your `root.zig`/`main.zig`/whatever your `root_source_module` is in `build.zig`:

```zig
pub const module_options = .{
    .gpl_compatible = true,
};
```

It is an affirmation that your dynamic module is GPL-compatible. Internally, this [exports `plugin_is_GPL_compatible`](https://www.gnu.org/software/emacs/manual/html_node/elisp/Module-Initialization.html), without which Emacs will refuse to load the module.