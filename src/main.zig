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

export fn _start() callconv(.Naked) noreturn {
    while (true) {}
}
