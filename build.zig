pub fn build(b: *std.Build) void {
    // a build tool, it runs on the host
    const module = b.createModule(.{
        .root_source_file = b.path("src/patch.zig"),
        .target = b.graph.host,
        .optimize = b.standardOptimizeOption(.{}),
    });
    const exe = b.addExecutable(.{ .name = "patch", .root_module = module });
    b.installArtifact(exe);

    {
        const source = b.option(std.Build.LazyPath, "source", "Directory to patch for namedLazyPath(\"patched\"), needs patches");
        const patches = b.option([]const std.Build.LazyPath, "patches", "Patches applied to source, in order");
        b.addNamedLazyPath("patched", if (source != null or patches != null) patchDir(
            b,
            exe,
            source orelse std.process.fatal("patch: the patches option needs the source option", .{}),
            patches orelse std.process.fatal("patch: the source option needs the patches option", .{}),
        ) else failingDir(b, "patch: namedLazyPath(\"patched\") needs the source and patches options"));
    }

    {
        const test_step = b.step("test", "Run the tests");
        test_step.dependOn(&b.addRunArtifact(b.addTest(.{ .root_module = module })).step);
    }
}

fn patchDir(
    b: *std.Build,
    exe: *std.Build.Step.Compile,
    source: std.Build.LazyPath,
    patches: []const std.Build.LazyPath,
) std.Build.LazyPath {
    if (patches.len == 0) std.process.fatal("patch: the patches option is empty", .{});
    const run = b.addRunArtifact(exe);
    run.addDirectoryArg(source);
    const dir = run.addOutputDirectoryArg("patched");
    // the build system only hashes a directory arg's path, this tracks its files
    _ = run.addDepFileOutputArg("deps.d");
    for (patches) |p| run.addFileArg(p);
    return dir;
}

/// A directory that fails the build with `msg` if anything uses it, so an
/// output without its options gives a clear error.
fn failingDir(b: *std.Build, msg: []const u8) std.Build.LazyPath {
    const write = b.addWriteFiles();
    write.step.dependOn(&b.addFail(msg).step);
    return write.getDirectory();
}

const std = @import("std");
