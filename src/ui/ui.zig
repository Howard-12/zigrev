pub const main_viewport = @import("window/main_viewport.zig");
pub const memory_editor = @import("window/memory_editor.zig");

const zigrev = @import("root").zigrev;
const SharedState = zigrev.SharedState;

// TODO: define default layout and have options to reset to default layout (custom layout if possible)
// TODO: add options to open/close wndow from the view menu

const std = @import("std");
const Self = @This();

const Window = union(enum) {
    main_viewport: main_viewport,
    memory_editor: memory_editor,

    pub fn update(self: *Window, state: *SharedState) void {
        switch (self.*) {
            inline else => |*win| win.update(state),
        }
    }

    pub fn draw(self: *Window, state: *SharedState) void {
        switch (self.*) {
            inline else => |*win| win.draw(state),
        }
    }

    pub fn deinit(self: *Window) void {
        switch (self.*) {
            inline else => |*win| win.deinit(),
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

// The purpose of this function is to sepatate the logic from the ui view keep the ui code clean (hopefully)
// Also store temp data if needed
pub fn update(self: *Self, state: *SharedState) void {
    for (&self.windows) |*win| {
        win.update(state);
    }
}

pub fn draw(self: *Self, state: *SharedState) void {
    for (&self.windows) |*win| {
        win.draw(state);
    }
}

pub fn deinit(self: *Self) void {
    for (&self.windows) |*win| {
        win.deinit();
    }
}
