pub const main_viewport = @import("window/main_viewport.zig");
pub const memory_editor = @import("window/memory_editor.zig");

// TODO: define default layout and have options to reset to default layout (custom layout if possible)

const std = @import("std");
const Self = @This();

const Window = union(enum) {
    main_viewport: main_viewport,
    memory_editor: memory_editor,

    pub fn draw(self: *Window) void {
        switch (self.*) {
            inline else => |*win| win.draw(),
        }
    }
};

windows: [2]Window,

pub fn init() Self {
    var self = Self{
        .windows = undefined,
    };

    self.windows[0] = Window { .main_viewport = main_viewport.init() };
    self.windows[1] = Window { .memory_editor = memory_editor.init() };

    return self;
}

pub fn draw(self: *Self) void {
    for (&self.windows) |*win| {
        win.draw();
    }
}

pub fn deinit(self: *Self) void {
    _ = self;

}
