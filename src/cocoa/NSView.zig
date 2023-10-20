const std = @import("std");

pub const AutoresizingMask = packed struct {
    min_x_margin: bool,
    width_sizable: bool,
    max_x_margin: bool,
    min_y_margin: bool,
    height_sizable: bool,
    max_y_margin: bool,
    _padding: u58 = 0,
    pub const not_sizable: AutoresizingMask = .{
        .min_x_margin = false,
        .width_sizable = false,
        .max_x_margin = false,
        .min_y_margin = false,
        .height_sizable = false,
        .max_y_margin = false,
    };
    comptime {
        std.debug.assert(@sizeOf(@This()) == @sizeOf(u64));
        std.debug.assert(@bitSizeOf(@This()) == @bitSizeOf(u64));
    }
};

pub const BorderType = enum(u64) {
    NoBorder = 0,
    LineBorder = 1,
    BezelBorder = 2,
    GrooveBorder = 3,
};
