const cocoa = @import("../cocoa.zig");
const objc = @import("zig-objc");

pub const LoopMode = enum {
    default,
    common_modes,
    event_tracking,
    modal_panel,
};

pub fn Mode(mode: LoopMode) objc.Object {
    return switch (mode) {
        .default => cocoa.NSString("kCFRunLoopDefaultMode"),
        .common_modes => cocoa.NSString("kCFRunLoopCommonModes"),
        .modal_panel => cocoa.NSString("NSModalPanelRunLoopMode"),
        .event_tracking => cocoa.NSString("NSEventTrackingRunLoopMode"),
    };
}
