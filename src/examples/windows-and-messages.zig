const std = @import("std");
const cocoa = @import("cocoa");
const objc = @import("zig-objc");

const logger = std.log.scoped(.cocoa);

fn setup() void {
    const Window = objc.allocateClassPair(objc.getClass("NSWindow").?, "Window").?;
    const window = struct {
        fn initInner(
            target: objc.c.id,
            sel: objc.c.SEL,
        ) callconv(.C) objc.c.id {
            _ = sel;
            const self = objc.Object.fromId(target);
            const mask: cocoa.NSWindow.StyleMask = .{
                .miniaturizable = true,
                .titled = true,
                .fullscreen = false,
                .fullsize_content_view = true,
                .resizable = true,
                .closable = true,
            };
            self.msgSendSuper(
                objc.getClass("NSWindow").?,
                void,
                "initWithContentRect:styleMask:backing:defer:",
                .{
                    cocoa.NSRect.make(10, 10, 300, 300),
                    mask,
                    .Buffered,
                    .NO,
                },
            );
            self.msgSend(void, "setTitle:", .{cocoa.NSString("Window and Messages")});
            self.setProperty("isVisible", .{.YES});
            const center = objc.getClass("NSNotificationCenter").?.msgSend(objc.Object, "defaultCenter", .{});
            center.msgSend(void, "addObserver:selector:name:object:", .{
                self,
                objc.sel("windowDidEnterFullScreen:"),
                cocoa.NSNotification.name(.WindowDidEnterFullScreen),
                self,
            });
            center.msgSend(void, "addObserver:selector:name:object:", .{
                self,
                objc.sel("windowDidExitFullScreen:"),
                cocoa.NSNotification.name(.WindowDidExitFullScreen),
                self,
            });
            center.msgSend(void, "addObserver:selector:name:object:", .{
                self,
                objc.sel("windowDidMove:"),
                cocoa.NSNotification.name(.WindowDidMove),
                self,
            });
            center.msgSend(void, "addObserver:selector:name:object:", .{
                self,
                objc.sel("windowDidResize:"),
                cocoa.NSNotification.name(.WindowDidResize),
                self,
            });
            center.msgSend(void, "addObserver:selector:name:object:", .{
                self,
                objc.sel("windowDidMiniaturize:"),
                cocoa.NSNotification.name(.WindowDidMiniaturize),
                self,
            });
            center.msgSend(void, "addObserver:selector:name:object:", .{
                self,
                objc.sel("windowDidDeMiniaturize:"),
                cocoa.NSNotification.name(.WindowDidDeMiniaturize),
                self,
            });
            return self.value;
        }
        fn deminiaturizeInner(
            target: objc.c.id,
            sel: objc.c.SEL,
            notification: objc.c.id,
        ) callconv(.C) void {
            _ = notification;
            _ = sel;
            _ = target;
            logger.info("de-miniaturize", .{});
        }
        fn enterFullScreenInner(
            target: objc.c.id,
            sel: objc.c.SEL,
            notification: objc.c.id,
        ) callconv(.C) void {
            _ = notification;
            _ = sel;
            _ = target;
            logger.info("enter full screen", .{});
        }
        fn exitFullScreenInner(
            target: objc.c.id,
            sel: objc.c.SEL,
            notification: objc.c.id,
        ) callconv(.C) void {
            _ = notification;
            _ = sel;
            _ = target;
            logger.info("exit full screen", .{});
        }
        fn moveInner(
            target: objc.c.id,
            sel: objc.c.SEL,
            notification: objc.c.id,
        ) callconv(.C) void {
            _ = notification;
            _ = sel;
            _ = target;
            logger.info("move", .{});
        }
        fn resizeInner(
            target: objc.c.id,
            sel: objc.c.SEL,
            notification: objc.c.id,
        ) callconv(.C) void {
            _ = notification;
            _ = sel;
            _ = target;
            logger.info("resize", .{});
        }
        fn miniaturizeInner(
            target: objc.c.id,
            sel: objc.c.SEL,
            notification: objc.c.id,
        ) callconv(.C) void {
            _ = notification;
            _ = sel;
            _ = target;
            logger.info("miniaturize", .{});
        }
        fn closeInner(
            target: objc.c.id,
            sel: objc.c.SEL,
            sender: objc.c.id,
        ) callconv(.C) objc.c.BOOL {
            _ = sel;
            _ = target;
            logger.info("closing!", .{});
            cocoa.NSApp().msgSend(void, "terminate:", .{sender});
            return cocoa.NO;
        }
    };
    Window.replaceMethod("init", window.initInner);
    Window.replaceMethod("windowDidDeMiniaturize:", window.deminiaturizeInner);
    Window.replaceMethod("windowDidEnterFullScreen:", window.enterFullScreenInner);
    Window.replaceMethod("windowDidExitFullScreen:", window.exitFullScreenInner);
    Window.replaceMethod("windowDidMove:", window.moveInner);
    Window.replaceMethod("windowDidResize:", window.resizeInner);
    Window.replaceMethod("windowDidMiniaturize:", window.miniaturizeInner);
    Window.replaceMethod("windowShouldClose:", window.closeInner);
    objc.registerClassPair(Window);
}

pub fn main() void {
    setup();
    const NSApp = cocoa.NSApp();
    const Window = objc.getClass("Window").?;
    const window1 = cocoa.alloc(Window);
    window1.msgSend(objc.Object, "init", .{}).msgSend(objc.Object, "autorelease", .{}).msgSend(void, "makeMainWindow", .{});
    NSApp.msgSend(void, "run", .{});
}
