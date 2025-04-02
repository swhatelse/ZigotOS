const VGA_WIDTH = 80;
const VGA_HEIGHT = 25;
const VGA_SIZE = VGA_WIDTH * VGA_HEIGHT;

pub const Colors = enum(u8) {
    Black = 0,
    Blue = 1,
    Green = 2,
    Cyan = 3,
    Red = 4,
    Magenta = 5,
    Brown = 6,
    LightGray = 7,
    DarkGray = 8,
    LightBlue = 9,
    LightGreen = 10,
    LightCyan = 11,
    LightRed = 12,
    LightMagenta = 13,
    LightBrown = 14,
    White = 15,
};

var row: usize = 0;
var column: usize = 0;
var color = vgaColor(Colors.LightGreen, Colors.Black);
var buffer = @as([*]volatile u16, @ptrFromInt(0xB8000));

fn vgaColor(fg: Colors, bg: Colors) u8 {
    return @intFromEnum(fg) | (@intFromEnum(bg) << 4);
}

fn vgaChar(uc: u8, col: u8) u16 {
    const c: u16 = col;

    return uc | (c << 8);
}

pub fn init() void {
    clear();
}

pub fn setColor(col: u8) void {
    color = col;
}

pub fn clear() void {
    @memset(buffer[0..VGA_SIZE], vgaChar(' ', color));
}

pub fn putCharAt(c: u8, col: u8, x: usize, y: usize) void {
    buffer[y * VGA_WIDTH + x] = vgaChar(c, col);
}

pub fn putChar(c: u8) void {
    putCharAt(c, color, column, row);
    column += 1;
    if (column == VGA_WIDTH) {
        column = 0;
        row += 1;
        if (row == VGA_HEIGHT)
            row = 0;
    }
}

pub fn puts(s: []const u8) void {
    for (s) |c|
        putChar(c);
}
