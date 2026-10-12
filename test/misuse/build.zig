//! Misuses zig-patch, each case must fail with a clear error, see ../build.zig.

pub fn build(b: *std.Build) void {
    const case = b.option(Case, "case", "The misuse to make") orelse std.debug.panic("missing -Dcase", .{});
    switch (case) {
        .std_without_std_patches => b.installArtifact(b.addExecutable(.{
            .name = "uses-std",
            .root_module = b.createModule(.{
                .root_source_file = b.path("main.zig"),
                .target = b.graph.host,
                .imports = &.{.{ .name = "std", .module = b.dependency("patch", .{}).module("std") }},
            }),
        })),
        .patched_without_options => installDir(b, b.dependency("patch", .{}).namedLazyPath("patched")),
        .source_without_patches => installDir(b, b.dependency("patch", .{ .source = b.path(".") }).namedLazyPath("patched")),
        .patches_without_source => installDir(b, b.dependency("patch", .{
            .patches = &[_]std.Build.LazyPath{b.path("build.zig")},
        }).namedLazyPath("patched")),
        .empty_patches => installDir(b, b.dependency("patch", .{
            .source = b.path("dir"),
            .patches = &[_]std.Build.LazyPath{},
        }).namedLazyPath("patched")),
        .empty_std_patches => _ = b.dependency("patch", .{ .std_patches = &[_]std.Build.LazyPath{} }),
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
    std_without_std_patches,
    patched_without_options,
    source_without_patches,
    patches_without_source,
    empty_patches,
    empty_std_patches,
    bad_patch,
};

const std = @import("std");
