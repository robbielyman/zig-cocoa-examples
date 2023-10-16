pub const NSPoint = extern struct {
    x: f64,
    y: f64,

    pub fn make(x: f64, y: f64) NSPoint {
        return .{
            .x = x,
            .y = y,
        };
    }
};

pub const NSSize = extern struct {
    width: f64,
    height: f64,

    pub fn make(w: f64, h: f64) NSSize {
        return .{
            .width = w,
            .height = h,
        };
    }
};

pub const NSRect = extern struct {
    origin: NSPoint,
    size: NSSize,

    pub fn make(x: f64, y: f64, w: f64, h: f64) NSRect {
        return .{
            .origin = .{ .x = x, .y = y },
            .size = .{ .width = w, .height = h },
        };
    }
};
