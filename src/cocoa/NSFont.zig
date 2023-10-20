const std = @import("std");

pub const Descriptor = struct {
    pub const SymbolicTraits = packed struct {
        italic: bool,
        bold: bool,
        _unused_1: u3 = 0,
        expanded: bool,
        condensed: bool,
        _unused_2: u3 = 0,
        monospace: bool,
        vertical: bool,
        ui_optimized: bool,
        _unused_3: u2 = 0,
        tight_leading: bool,
        loose_leading: bool,
        _padding: u15 = 0,

        comptime {
            std.debug.assert(@sizeOf(@This()) == @sizeOf(u32));
            std.debug.assert(@bitSizeOf(@This()) == @bitSizeOf(u32));
        }
    };
};
