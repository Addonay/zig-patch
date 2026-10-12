pub const sees_patched_std = @hasDecl(@import("std"), "patch_test_decl");
pub const subsub_sees_patched_std = @import("subsub").sees_patched_std;
