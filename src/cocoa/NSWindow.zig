const std = @import("std");
const objc = @import("zig-objc");
const cocoa = @import("../cocoa.zig");

pub fn class() objc.Class {
    return objc.getClass("NSWindow").?;
}

pub const StyleMask = packed struct {
    titled: bool,
    closable: bool,
    miniaturizable: bool,
    resizable: bool,
    utility_window: bool = false,
    _unused_1: bool = false,
    doc_modal_window: bool = false,
    nonactivating_panel: bool = false,
    _unused_2: u4 = 0,
    unified_title_and_toolbar: bool = false,
    hud_window: bool = false,
    fullscreen: bool,
    fullsize_content_view: bool,
    _padding: u48 = 0,

    pub const default: StyleMask = .{
        .titled = true,
        .closable = true,
        .miniaturizable = true,
        .fullscreen = false,
        .fullsize_content_view = true,
        .resizable = true,
    };

    comptime {
        std.debug.assert(@sizeOf(@This()) == @sizeOf(u64));
        std.debug.assert(@bitSizeOf(@This()) == @bitSizeOf(u64));
    }
};

pub const BackingStore = enum(c_uint) {
    Retained = 0,
    Nonretained = 1,
    Buffered = 2,
};

pub fn initSuperWith(window: objc.Object, contentRect: cocoa.NSRect, styleMask: StyleMask, backing: BackingStore, deferred: bool) objc.Object {
    const is_defer = if (deferred) cocoa.YES else cocoa.NO;
    return window.msgSendSuper(
        objc.getClass("NSWindow").?,
        objc.Object,
        "initWithContentRect:styleMask:backing:defer:",
        .{ contentRect, styleMask, backing, is_defer },
    );
}

pub fn initWith(window: objc.Object, contentRect: cocoa.NSRect, styleMask: StyleMask, backing: BackingStore, deferred: bool) objc.Object {
    const is_defer = if (deferred) cocoa.YES else cocoa.NO;
    return window.msgSend(objc.Object, "initWithContentRect:styleMask:backing:defer:", .{
        contentRect,
        styleMask,
        backing,
        is_defer,
    });
}
