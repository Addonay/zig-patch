//! Misuses zig-patch, each case must fail with a clear error, see ../build.zig.

pub fn build(b: *std.Build) void {
    const case = b.option(Case, "case", "The misuse to make") orelse std.debug.panic("missing -Dcase", .{});
    switch (case) {
        .patched_without_options => installDir(b, b.dependency("patch", .{}).namedLazyPath("patched")),
        .source_without_patches => installDir(b, b.dependency("patch", .{ .source = b.path(".") }).namedLazyPath("patched")),
        .patches_without_source => installDir(b, b.dependency("patch", .{
            .patches = &[_]std.Build.LazyPath{b.path("build.zig")},
        }).namedLazyPath("patched")),
        .empty_patches => installDir(b, b.dependency("patch", .{
            .source = b.path("dir"),
            .patches = &[_]std.Build.LazyPath{},
        }).namedLazyPath("patched")),
        .bad_patch => installDir(b, b.dependency("patch", .{
            .source = b.path("dir"),
            .patches = &[_]std.Build.LazyPath{b.path("bad.patch")},
        }).namedLazyPath("patched")),
    }
}

fn installDir(b: *std.Build, dir: std.Build.LazyPath) void {
    b.installDirectory(.{ .source_dir = dir, .install_dir = .prefix, .install_subdir = "patched" });
}

pub const Case = enum {
    patched_without_options,
    source_without_patches,
    patches_without_source,
    empty_patches,
    bad_patch,
};

const std = @import("std");
