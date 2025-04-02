const term = @import("terminal.zig");

// Boot headers values
const ALIGN = 1 << 0;
const MEMINFO = 1 << 1;
const FLAGS = ALIGN | MEMINFO;
const MAGIC = 0x1BADB002;
const CHECKSUM = -(MAGIC + FLAGS);

const MultiBootHeader = packed struct {
    magic: i32 = MAGIC,
    flags: i32 = FLAGS,
    checksum: i32 = CHECKSUM,
    padding: i32 = 0,
};

export var multibootheader: MultiBootHeader align(4) linksection(".multiboot") = .{};

var stack: [16 * 1024]u8 align(16) linksection(".bss") = undefined;

export fn _start() callconv(.Naked) noreturn {
    asm volatile (
        \\ movl %[stack_top], %%esp
        \\ movl %%esp, %%ebp
        \\ call %[kmain:P]
        :
        : [stack_top] "i" (@as([*]align(16) u8, @ptrCast(&stack)) + @sizeOf(@TypeOf(stack))),
          [kmain] "X" (&kmain),
    );
}

fn kmain() callconv(.C) void {
    term.init();
    term.puts("Hello Zig Kernel!");
    while (true) {}
}
