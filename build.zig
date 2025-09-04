const std = @import("std");
const cimgui = @import("cimgui_zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // cimgui zig
    const cimgui_dep = b.dependency("cimgui_zig", .{
        .target = target,
        .optimize = optimize,
        .platform = cimgui.Platform.GLFW,
        .renderer = cimgui.Renderer.OpenGL3,
    });
    const cimgui_artifact = cimgui_dep.artifact("cimgui");
 
    // eecutable
    const exe = b.addExecutable(.{
        .name = "zigrev",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "gl", .module = cimgui_artifact.root_module.import_table.get("gl").? },
            },
        }),
    });
    exe.linkLibrary(cimgui_artifact);

    b.installArtifact(exe);

    // run option
    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // test
    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);

    // run option
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_exe_tests.step);
}
