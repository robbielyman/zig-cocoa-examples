const std = @import("std");

const programs: []const []const u8 = &.{
    "hello-world",
    "application",
    "application-with-message-loop",
    "application-idle",
    "drawing",
    "windows-and-messages",
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zig_objc = b.dependency("zig_objc", .{
        .target = target,
        .optimize = optimize,
    });

    const cocoa = b.addModule("cocoa", .{
        .source_file = .{ .path = "src/cocoa.zig" },
        .dependencies = &.{.{
            .name = "zig-objc",
            .module = zig_objc.module("objc"),
        }},
    });

    for (programs) |program_name| {
        const prog = b.addExecutable(.{
            .name = program_name,
            .root_source_file = .{ .path = std.fmt.allocPrint(b.allocator, "src/examples/{s}.zig", .{program_name}) catch @panic("OOM!") },
            .target = target,
            .optimize = optimize,
        });
        b.installArtifact(prog);
        prog.linkFramework("Cocoa");
        prog.addModule("zig-objc", zig_objc.module("objc"));
        prog.addModule("cocoa", cocoa);
        const run_cmd = b.addRunArtifact(prog);
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }
        const run_step = b.step(program_name, "Run the app");
        run_step.dependOn(&run_cmd.step);
    }

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
