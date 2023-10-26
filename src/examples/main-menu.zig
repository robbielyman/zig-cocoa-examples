const std = @import("std");
const cocoa = @import("cocoa");
const objc = @import("zig-objc");
const assert = std.debug.assert;

const logger = std.log.scoped(.App);

fn setup() !void {
    const Window = objc.allocateClassPair(objc.getClass("NSWindow").?, "Window").?;
    defer objc.registerClassPair(Window);
    const inner = struct {
        fn init(target: objc.c.id, sel: objc.c.SEL) callconv(.C) objc.c.id {
            _ = sel;
            const self = objc.Object.fromId(target);
            const NSApp = cocoa.NSApp();

            // create menu bar
            NSApp.setProperty("mainMenu", .{
                cocoa.alloc(objc.getClass("NSMenu").?)
                    .msgSend(objc.Object, "init", .{})
                    .msgSend(objc.Object, "autorelease", .{}),
            });
            const mainMenu = NSApp.msgSend(objc.Object, "mainMenu", .{});
            const NSMenu = objc.getClass("NSMenu").?;
            const NSMenuItem = objc.getClass("NSMenuItem").?;
            mainMenu.msgSend(void, "addItem:", .{
                cocoa.alloc(NSMenuItem)
                    .msgSend(objc.Object, "init", .{})
                    .msgSend(objc.Object, "autorelease", .{}),
            });
            const first_item = mainMenu.msgSend(objc.Object, "itemArray", .{})
                .msgSend(objc.Object, "objectAtIndex:", .{@as(u64, 0)});
            const process_name = objc.getClass("NSProcessInfo").?
                .msgSend(objc.Object, "processInfo", .{})
                .msgSend(objc.Object, "processName", .{});
            first_item.msgSend(void, "setSubmenu:", .{
                cocoa.alloc(NSMenu)
                    .msgSend(objc.Object, "initWithTitle:", .{
                    process_name,
                })
                    .msgSend(objc.Object, "autorelease", .{}),
            });
            const name_str = std.mem.sliceTo(process_name.msgSend([*:0]const u8, "UTF8String", .{}), 0);
            var buf: [1024]u8 = undefined;
            var fba = std.heap.FixedBufferAllocator.init(&buf);
            const allocator = fba.allocator();
            const str = std.fmt.allocPrintZ(allocator, "About {s}", .{name_str}) catch @panic("OOM!");
            const mainBundle = objc.getClass("NSBundle").?
                .msgSend(objc.Object, "mainBundle", .{});
            first_item.msgSend(objc.Object, "submenu", .{})
                .msgSend(void, "addItem:", .{
                cocoa.alloc(NSMenuItem)
                    .msgSend(objc.Object, "initWithTitle:action:keyEquivalent:", .{
                    mainBundle.msgSend(objc.Object, "localizedStringForKey:value:table:", .{
                        cocoa.NSString(str),
                        cocoa.nil,
                        cocoa.nil,
                    }),
                    objc.sel("orderFrontStandardAboutPanel:").value,
                    cocoa.NSString(""),
                })
                    .msgSend(objc.Object, "autorelease", .{}),
            });
            allocator.free(str);

            first_item.msgSend(objc.Object, "submenu", .{})
                .msgSend(void, "addItem:", .{
                NSMenuItem.msgSend(objc.Object, "separatorItem", .{}),
            });
            first_item.msgSend(objc.Object, "submenu", .{})
                .msgSend(void, "addItem:", .{
                cocoa.alloc(NSMenuItem)
                    .msgSend(objc.Object, "initWithTitle:action:keyEquivalent:", .{
                    mainBundle.msgSend(objc.Object, "localizedStringForKey:value:table:", .{
                        cocoa.NSString("Services"),
                        cocoa.nil,
                        cocoa.nil,
                    }),
                    cocoa.nil,
                    cocoa.NSString(""),
                })
                    .msgSend(objc.Object, "autorelease", .{}),
            });
            first_item.msgSend(objc.Object, "submenu", .{})
                .msgSend(objc.Object, "itemArray", .{})
                .msgSend(objc.Object, "objectAtIndex:", .{@as(u64, 2)})
                .msgSend(void, "setSubmenu:", .{
                cocoa.alloc(NSMenu)
                    .msgSend(objc.Object, "init", .{})
                    .msgSend(objc.Object, "autorelease", .{}),
            });
            NSApp.setProperty("servicesMenu", .{
                NSApp.msgSend(objc.Object, "mainMenu", .{})
                    .msgSend(objc.Object, "itemArray", .{})
                    .msgSend(objc.Object, "objectAtIndex:", .{@as(u64, 0)})
                    .msgSend(objc.Object, "submenu", .{})
                    .msgSend(objc.Object, "itemArray", .{})
                    .msgSend(objc.Object, "objectAtIndex:", .{@as(u64, 2)})
                    .msgSend(objc.Object, "submenu", .{}),
            });
            const hide_self = std.fmt.allocPrintZ(allocator, "Hide {s}", .{name_str}) catch @panic("OOM!");
            first_item.msgSend(objc.Object, "submenu", .{})
                .msgSend(void, "addItem:", .{
                cocoa.alloc(NSMenuItem)
                    .msgSend(objc.Object, "initWithTitle:action:keyEquivalent:", .{
                    mainBundle.msgSend(objc.Object, "localizedStringForKey:value:table:", .{
                        cocoa.NSString(hide_self),
                        cocoa.nil,
                        cocoa.nil,
                    }),
                    objc.sel("hide:"),
                    cocoa.NSString("h"),
                })
                    .msgSend(objc.Object, "autorelease", .{}),
            });
            allocator.free(hide_self);
            first_item.msgSend(objc.Object, "submenu", .{})
                .msgSend(void, "addItem:", .{
                cocoa.alloc(NSMenuItem)
                    .msgSend(objc.Object, "initWithTitle:action:keyEquivalent:", .{
                    mainBundle.msgSend(objc.Object, "localizedStringForKey:value:table:", .{
                        cocoa.NSString("Hide Other"),
                        cocoa.nil,
                        cocoa.nil,
                    }),
                    objc.sel("hideOtherApplications:"),
                    cocoa.NSString("h"),
                })
                    .msgSend(objc.Object, "autorelease", .{}),
            });
            const mod_flags: cocoa.NSEvent.ModifierFlags = .{
                .CapsLock = false,
                .Shift = false,
                .Control = false,
                .Option = true,
                .Command = true,
                .NumericPad = false,
                .Help = false,
                .Function = false,
            };
            first_item.msgSend(objc.Object, "submenu", .{})
                .msgSend(objc.Object, "itemArray", .{})
                .msgSend(objc.Object, "objectAtIndex:", .{@as(u64, 4)})
                .setProperty("keyEquivalentModifierMask", .{mod_flags});
            first_item.msgSend(objc.Object, "submenu", .{})
                .msgSend(void, "addItem:", .{
                cocoa.alloc(NSMenuItem)
                    .msgSend(objc.Object, "initWithTitle:action:keyEquivalent:", .{
                    mainBundle.msgSend(objc.Object, "localizedStringForKey:value:table:", .{
                        cocoa.NSString("Show All"),
                        cocoa.nil,
                        cocoa.nil,
                    }),
                    objc.sel("unhideAllApplications:"),
                    cocoa.NSString(""),
                })
                    .msgSend(objc.Object, "autorelease", .{}),
            });
            first_item.msgSend(objc.Object, "submenu", .{})
                .msgSend(void, "addItem:", .{
                NSMenuItem.msgSend(objc.Object, "separatorItem", .{}),
            });
            const quit_self = std.fmt.allocPrintZ(allocator, "Quit {s}", .{name_str}) catch @panic("OOM!");
            first_item.msgSend(objc.Object, "submenu", .{})
                .msgSend(void, "addItem:", .{
                cocoa.alloc(NSMenuItem)
                    .msgSend(objc.Object, "initWithTitle:action:keyEquivalent:", .{
                    mainBundle.msgSend(objc.Object, "localizedStringForKey:value:table:", .{
                        cocoa.NSString(quit_self),
                        cocoa.nil,
                        cocoa.nil,
                    }),
                    objc.sel("terminate:"),
                    cocoa.NSString("q"),
                })
                    .msgSend(objc.Object, "autorelease", .{}),
            });

            // Create File submenu
            mainMenu.msgSend(void, "addItem:", .{
                cocoa.alloc(NSMenuItem)
                    .msgSend(objc.Object, "init", .{})
                    .msgSend(objc.Object, "autorelease", .{}),
            });
            mainMenu.msgSend(objc.Object, "itemArray", .{})
                .msgSend(objc.Object, "objectAtIndex:", .{@as(u64, 1)})
                .setProperty("submenu", .{
                cocoa.alloc(NSMenu)
                    .msgSend(objc.Object, "initWithTitle:", .{
                    mainBundle.msgSend(objc.Object, "localizedStringForKey:value:table:", .{
                        cocoa.NSString("File"),
                        cocoa.nil,
                        cocoa.nil,
                    })
                        .msgSend(objc.Object, "autorelease", .{}),
                }),
            });
            const file_submenu = mainMenu.msgSend(objc.Object, "itemArray", .{})
                .msgSend(objc.Object, "objectAtIndex:", .{@as(u64, 1)})
                .msgSend(objc.Object, "submenu", .{});
            file_submenu.msgSend(void, "addItem:", .{
                cocoa.alloc(NSMenuItem)
                    .msgSend(objc.Object, "initWithTitle:action:keyEquivalent:", .{
                    mainBundle.msgSend(objc.Object, "localizedStringForKey:value:table:", .{
                        cocoa.NSString("New"),
                        cocoa.nil,
                        cocoa.nil,
                    }),
                    objc.sel("fileNew:"),
                    cocoa.NSString("n"),
                })
                    .msgSend(objc.Object, "autorelease", .{}),
            });
            file_submenu.msgSend(void, "addItem:", .{
                cocoa.alloc(NSMenuItem)
                    .msgSend(objc.Object, "initWithTitle:action:keyEquivalent:", .{
                    mainBundle.msgSend(objc.Object, "localizedStringForKey:value:table:", .{
                        cocoa.NSString("Open"),
                        cocoa.nil,
                        cocoa.nil,
                    }),
                    objc.sel("fileOpen:"),
                    cocoa.NSString("o"),
                })
                    .msgSend(objc.Object, "autorelease", .{}),
            });
            file_submenu.msgSend(void, "addItem:", .{
                cocoa.alloc(NSMenuItem)
                    .msgSend(objc.Object, "initWithTitle:action:keyEquivalent:", .{
                    mainBundle.msgSend(objc.Object, "localizedStringForKey:value:table:", .{
                        cocoa.NSString("Close"),
                        cocoa.nil,
                        cocoa.nil,
                    }),
                    objc.sel("fileClose:"),
                    cocoa.NSString("w"),
                })
                    .msgSend(objc.Object, "autorelease", .{}),
            });

            // Create Edit submenu
            mainMenu.msgSend(void, "addItem:", .{
                cocoa.alloc(NSMenuItem)
                    .msgSend(objc.Object, "init", .{})
                    .msgSend(objc.Object, "autorelease", .{}),
            });
            mainMenu.msgSend(objc.Object, "itemArray", .{})
                .msgSend(objc.Object, "objectAtIndex:", .{@as(u64, 2)})
                .setProperty("submenu", .{
                cocoa.alloc(NSMenu)
                    .msgSend(objc.Object, "initWithTitle:", .{
                    mainBundle.msgSend(objc.Object, "localizedStringForKey:value:table:", .{
                        cocoa.NSString("Edit"),
                        cocoa.nil,
                        cocoa.nil,
                    })
                        .msgSend(objc.Object, "autorelease", .{}),
                }),
            });
            const edit_submenu = mainMenu.msgSend(objc.Object, "itemArray", .{})
                .msgSend(objc.Object, "objectAtIndex:", .{@as(u64, 2)})
                .msgSend(objc.Object, "submenu", .{});
            edit_submenu.msgSend(void, "addItem:", .{
                cocoa.alloc(NSMenuItem)
                    .msgSend(objc.Object, "initWithTitle:action:keyEquivalent:", .{
                    mainBundle.msgSend(objc.Object, "localizedStringForKey:value:table:", .{
                        cocoa.NSString("Undo"),
                        cocoa.nil,
                        cocoa.nil,
                    }),
                    objc.sel("editUndo:"),
                    cocoa.NSString("z"),
                })
                    .msgSend(objc.Object, "autorelease", .{}),
            });
            edit_submenu.msgSend(void, "addItem:", .{
                cocoa.alloc(NSMenuItem)
                    .msgSend(objc.Object, "initWithTitle:action:keyEquivalent:", .{
                    mainBundle.msgSend(objc.Object, "localizedStringForKey:value:table:", .{
                        cocoa.NSString("Redo"),
                        cocoa.nil,
                        cocoa.nil,
                    }),
                    objc.sel("editRedo:"),
                    cocoa.NSString("Z"),
                })
                    .msgSend(objc.Object, "autorelease", .{}),
            });
            edit_submenu.msgSend(void, "addItem:", .{
                NSMenuItem.msgSend(objc.Object, "separatorItem", .{}),
            });
            edit_submenu.msgSend(void, "addItem:", .{
                cocoa.alloc(NSMenuItem)
                    .msgSend(objc.Object, "initWithTitle:action:keyEquivalent:", .{
                    mainBundle.msgSend(objc.Object, "localizedStringForKey:value:table:", .{
                        cocoa.NSString("Cut"),
                        cocoa.nil,
                        cocoa.nil,
                    }),
                    objc.sel("editCut:"),
                    cocoa.NSString("x"),
                })
                    .msgSend(objc.Object, "autorelease", .{}),
            });
            edit_submenu.msgSend(void, "addItem:", .{
                cocoa.alloc(NSMenuItem)
                    .msgSend(objc.Object, "initWithTitle:action:keyEquivalent:", .{
                    mainBundle.msgSend(objc.Object, "localizedStringForKey:value:table:", .{
                        cocoa.NSString("Copy"),
                        cocoa.nil,
                        cocoa.nil,
                    }),
                    objc.sel("editCopy:"),
                    cocoa.NSString("c"),
                })
                    .msgSend(objc.Object, "autorelease", .{}),
            });
            edit_submenu.msgSend(void, "addItem:", .{
                cocoa.alloc(NSMenuItem)
                    .msgSend(objc.Object, "initWithTitle:action:keyEquivalent:", .{
                    mainBundle.msgSend(objc.Object, "localizedStringForKey:value:table:", .{
                        cocoa.NSString("Paste"),
                        cocoa.nil,
                        cocoa.nil,
                    }),
                    objc.sel("editPaste:"),
                    cocoa.NSString("v"),
                })
                    .msgSend(objc.Object, "autorelease", .{}),
            });
            edit_submenu.msgSend(void, "addItem:", .{
                cocoa.alloc(NSMenuItem)
                    .msgSend(objc.Object, "initWithTitle:action:keyEquivalent:", .{
                    mainBundle.msgSend(objc.Object, "localizedStringForKey:value:table:", .{
                        cocoa.NSString("Delete"),
                        cocoa.nil,
                        cocoa.nil,
                    }),
                    objc.sel("editDelete:"),
                    cocoa.NSString(&.{0x08}),
                })
                    .msgSend(objc.Object, "autorelease", .{}),
            });
            edit_submenu.msgSend(void, "addItem:", .{
                cocoa.alloc(NSMenuItem)
                    .msgSend(objc.Object, "initWithTitle:action:keyEquivalent:", .{
                    mainBundle.msgSend(objc.Object, "localizedStringForKey:value:table:", .{
                        cocoa.NSString("Select All"),
                        cocoa.nil,
                        cocoa.nil,
                    }),
                    objc.sel("editSelectAll:"),
                    cocoa.NSString("a"),
                })
                    .msgSend(objc.Object, "autorelease", .{}),
            });

            // create View submenu
            mainMenu.msgSend(void, "addItem:", .{
                cocoa.alloc(NSMenuItem)
                    .msgSend(objc.Object, "init", .{})
                    .msgSend(objc.Object, "autorelease", .{}),
            });
            mainMenu.msgSend(objc.Object, "itemArray", .{})
                .msgSend(objc.Object, "objectAtIndex:", .{@as(u64, 3)})
                .setProperty("submenu", .{
                cocoa.alloc(NSMenu)
                    .msgSend(objc.Object, "initWithTitle:", .{
                    mainBundle.msgSend(objc.Object, "localizedStringForKey:value:table:", .{
                        cocoa.NSString("View"),
                        cocoa.nil,
                        cocoa.nil,
                    }),
                })
                    .msgSend(objc.Object, "autorelease", .{}),
            });

            // create Windows submenu
            mainMenu.msgSend(void, "addItem:", .{
                cocoa.alloc(NSMenuItem)
                    .msgSend(objc.Object, "init", .{})
                    .msgSend(objc.Object, "autorelease", .{}),
            });
            mainMenu.msgSend(objc.Object, "itemArray", .{})
                .msgSend(objc.Object, "objectAtIndex:", .{@as(u64, 4)})
                .setProperty("submenu", .{
                cocoa.alloc(NSMenu)
                    .msgSend(objc.Object, "initWithTitle:", .{
                    mainBundle.msgSend(objc.Object, "localizedStringForKey:value:table:", .{
                        cocoa.NSString("Window"),
                        cocoa.nil,
                        cocoa.nil,
                    }),
                })
                    .msgSend(objc.Object, "autorelease", .{}),
            });
            NSApp.setProperty("windowsMenu", .{
                mainMenu.msgSend(objc.Object, "itemArray", .{})
                    .msgSend(objc.Object, "objectAtIndex:", .{@as(u64, 4)})
                    .msgSend(objc.Object, "submenu", .{}),
            });

            mainMenu.msgSend(void, "addItem:", .{
                cocoa.alloc(NSMenuItem)
                    .msgSend(objc.Object, "init", .{})
                    .msgSend(objc.Object, "autorelease", .{}),
            });
            mainMenu.msgSend(objc.Object, "itemArray", .{})
                .msgSend(objc.Object, "objectAtIndex:", .{@as(u64, 5)})
                .setProperty("submenu", .{
                cocoa.alloc(NSMenu)
                    .msgSend(objc.Object, "initWithTitle:", .{
                    mainBundle.msgSend(objc.Object, "localizedStringForKey:value:table:", .{
                        cocoa.NSString("Help"),
                        cocoa.nil,
                        cocoa.nil,
                    }),
                })
                    .msgSend(objc.Object, "autorelease", .{}),
            });
            NSApp.setProperty("helpMenu", .{
                mainMenu.msgSend(objc.Object, "itemArray", .{})
                    .msgSend(objc.Object, "objectAtIndex:", .{@as(u64, 5)})
                    .msgSend(objc.Object, "submenu", .{}),
            });

            self.msgSendSuper(
                objc.getClass("NSWindow").?,
                void,
                "initWithContentRect:styleMask:backing:defer:",
                .{
                    cocoa.NSRect.make(100, 100, 300, 300),
                    cocoa.NSWindow.StyleMask.default,
                    .Buffered,
                    .NO,
                },
            );
            self.setProperty("title", .{cocoa.NSString("MainMenu example")});
            self.setProperty("isVisible", .{.YES});
            return self.value;
        }
        fn fileNew(target: objc.c.id, sel: objc.c.SEL, sender: objc.c.id) callconv(.C) void {
            _ = sender;
            _ = sel;
            _ = target;
            logger.info("MainMenu/File/New", .{});
        }
        fn fileOpen(target: objc.c.id, sel: objc.c.SEL, sender: objc.c.id) callconv(.C) void {
            _ = sender;
            _ = sel;
            _ = target;
            logger.info("MainMenu/File/Open", .{});
        }
        fn fileClose(target: objc.c.id, sel: objc.c.SEL, sender: objc.c.id) callconv(.C) void {
            _ = sender;
            _ = sel;
            _ = target;
            logger.info("MainMenu/File/Close", .{});
        }
        fn editUndo(target: objc.c.id, sel: objc.c.SEL, sender: objc.c.id) callconv(.C) void {
            _ = sender;
            _ = sel;
            _ = target;
            logger.info("MainMenu/Edit/Undo", .{});
        }
        fn editRedo(target: objc.c.id, sel: objc.c.SEL, sender: objc.c.id) callconv(.C) void {
            _ = sender;
            _ = sel;
            _ = target;
            logger.info("MainMenu/Edit/Redo", .{});
        }
        fn editCut(target: objc.c.id, sel: objc.c.SEL, sender: objc.c.id) callconv(.C) void {
            _ = sender;
            _ = sel;
            _ = target;
            logger.info("MainMenu/Edit/Cut", .{});
        }
        fn editCopy(target: objc.c.id, sel: objc.c.SEL, sender: objc.c.id) callconv(.C) void {
            _ = sender;
            _ = sel;
            _ = target;
            logger.info("MainMenu/Edit/Copy", .{});
        }
        fn editPaste(target: objc.c.id, sel: objc.c.SEL, sender: objc.c.id) callconv(.C) void {
            _ = sender;
            _ = sel;
            _ = target;
            logger.info("MainMenu/Edit/Paste", .{});
        }
        fn editDelete(target: objc.c.id, sel: objc.c.SEL, sender: objc.c.id) callconv(.C) void {
            _ = sender;
            _ = sel;
            _ = target;
            logger.info("MainMenu/Edit/Delete", .{});
        }
        fn editSelectAll(target: objc.c.id, sel: objc.c.SEL, sender: objc.c.id) callconv(.C) void {
            _ = sender;
            _ = sel;
            _ = target;
            logger.info("MainMenu/Edit/SelectAll", .{});
        }
        fn shouldClose(target: objc.c.id, sel: objc.c.SEL, sender: objc.c.id) callconv(.C) bool {
            _ = sel;
            _ = target;
            cocoa.NSApp().msgSend(void, "terminate:", .{sender});
            return true;
        }
    };
    assert(try Window.addMethod("fileNew:", inner.fileNew));
    assert(try Window.addMethod("fileOpen:", inner.fileOpen));
    assert(try Window.addMethod("editUndo:", inner.editUndo));
    assert(try Window.addMethod("editRedo:", inner.editRedo));
    assert(try Window.addMethod("editCut:", inner.editCut));
    assert(try Window.addMethod("editCopy:", inner.editCopy));
    assert(try Window.addMethod("editPaste:", inner.editPaste));
    assert(try Window.addMethod("editSelectAll:", inner.editSelectAll));
    Window.replaceMethod("init", inner.init);
    Window.replaceMethod("windowShouldClose:", inner.shouldClose);
}

pub fn main() !void {
    try setup();
    const NSApp = cocoa.NSApp();
    cocoa.alloc(objc.getClass("Window").?)
        .msgSend(objc.Object, "init", .{})
        .msgSend(objc.Object, "autorelease", .{})
        .msgSend(void, "makeMainWindow", .{});
    NSApp.msgSend(void, "run", .{});
}
