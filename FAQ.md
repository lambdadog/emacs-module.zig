# FAQ
### Missing GPL affirmation
Emacs requires an affirmation in code that a dynamic module is GPL-compatible before loading it. With `emacs-module.zig`, this is done by adding the following to your root module (`root.zig`/`main.zig`/whatever `root_source_file` is set to in your `build.zig`):

```zig
pub const module_options = .{
    .gpl_compatible = true,
};
```
