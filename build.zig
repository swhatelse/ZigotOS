const std = @import("std");

pub fn build(b: *std.Build) void {
    var disabled_features = std.Target.Cpu.Feature.Set.empty;
    var enabled_features = std.Target.Cpu.Feature.Set.empty;

    disabled_features.addFeature(@intFromEnum(std.Target.x86.Feature.mmx));
    disabled_features.addFeature(@intFromEnum(std.Target.x86.Feature.sse));
    disabled_features.addFeature(@intFromEnum(std.Target.x86.Feature.sse2));
    disabled_features.addFeature(@intFromEnum(std.Target.x86.Feature.avx));
    disabled_features.addFeature(@intFromEnum(std.Target.x86.Feature.avx2));
    enabled_features.addFeature(@intFromEnum(std.Target.x86.Feature.soft_float));

    const target_query = std.Target.Query{
        .cpu_arch = std.Target.Cpu.Arch.x86,
        .os_tag = std.Target.Os.Tag.freestanding,
        .abi = std.Target.Abi.none,
        .cpu_features_sub = disabled_features,
        .cpu_features_add = enabled_features,
    };

    const optimize = b.standardOptimizeOption(.{});

    // Build kernel
    const kernel_elf = "ZigotOS.elf";
    const out_elf = "zig-out/bin/" ++ kernel_elf;
    const kernel = b.addExecutable(.{
        .name = kernel_elf,
        .root_source_file = b.path("src/main.zig"),
        .target = b.resolveTargetQuery(target_query),
        .optimize = optimize,
        .code_model = .kernel,
    });

    kernel.setLinkerScript(b.path("src/linker.ld"));
    b.installArtifact(kernel);

    const kernel_step = b.step("kernel", "Build the kernel");
    kernel_step.dependOn(&kernel.step);

    // Create boot image
    const isodir_path = "zig-out/isodir";
    const mkdir_isodir = b.addSystemCommand(&.{ "mkdir", "-p", isodir_path ++ "/boot/grub" });
    const mkdir_isodir_step = b.step("mk_isodir", "Create iso directory");
    mkdir_isodir_step.dependOn(&kernel.step);

    const copy_kernel = b.addSystemCommand(&.{ "cp", out_elf, isodir_path ++ "/boot/" ++ kernel_elf });
    const copy_kernel_step = b.step("copy_kernel", "Copy kernel");
    copy_kernel_step.dependOn(&mkdir_isodir.step);

    const copy_grub_cfg = b.addSystemCommand(&.{ "cp", "src/grub.cfg", isodir_path ++ "/boot/grub/grub.cfg" });
    const copy_grub_cfg_step = b.step("copy_grub_cfg", "Copy kernel");
    copy_grub_cfg_step.dependOn(&copy_kernel.step);

    const iso_path = isodir_path;
    const make_iso = b.addSystemCommand(&.{ "grub-mkrescue", "-o", iso_path ++ "/ZigotOS.iso", isodir_path });
    const make_iso_step = b.step("make_iso", "Copy kernel");
    make_iso_step.dependOn(&copy_grub_cfg.step);

    const build_iso_step = b.step("build_iso", "Build kernel iso");
    build_iso_step.dependOn(&make_iso.step);
}
