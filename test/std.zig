//! Every module, nested ones too, sees the patched std, with only its own
//! instance's patches.

comptime {
    if (!@hasDecl(std, "patch_test_decl")) @compileError("root module doesn't see the patched std");
    if (@hasDecl(std, "patch_stack_decl") != @import("options").stacked) @compileError("std has another instance's patches");
}

pub fn main() void {
    if (!@import("sub").sees_patched_std) @panic("submodule doesn't see the patched std");
    if (!@import("sub").subsub_sees_patched_std) @panic("nested submodule doesn't see the patched std");
}

const std = @import("std");
