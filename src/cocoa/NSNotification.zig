const objc = @import("zig-objc");
const cocoa = @import("../cocoa.zig");

pub const NotificationType = enum {
    WindowDidEnterFullScreen,
    WindowDidExitFullScreen,
    WindowDidMove,
    WindowDidResize,
    WindowDidMiniaturize,
    WindowDidDeMiniaturize,
};

pub fn name(notification: NotificationType) objc.Object {
    const str = switch (notification) {
        .WindowDidEnterFullScreen => "NSWindowDidEnterFullScreenNotification",
        .WindowDidExitFullScreen => "NSWindowDidExitFullScreenNotification",
        .WindowDidMove => "NSWindowDidMoveNotification",
        .WindowDidResize => "NSWindowDidResizeNotification",
        .WindowDidMiniaturize => "NSWindowDidMiniaturizeNotification",
        .WindowDidDeMiniaturize => "NSWindowDidDeMiniaturizeNotification",
    };
    return cocoa.NSString(str);
}
