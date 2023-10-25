pub const objc = @import("zig-objc");

pub fn colorWithSRGB(red: f64, green: f64, blue: f64, alpha: f64) objc.Object {
    const NSColor = objc.getClass("NSColor").?;
    return NSColor.msgSend(objc.Object, "colorWithSRGBRed:green:blue:alpha:", .{ red, green, blue, alpha });
}
