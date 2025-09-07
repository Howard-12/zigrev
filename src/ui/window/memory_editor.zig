const std = @import("std");
const imgui = @import("root").zigrev.c;

const Self = @This();

flags: ?imgui.ImGuiWindowFlags,
editor_window: ?*imgui.MemoryEditor,
buf: [256]u8,

pub fn init() Self {
    var self = Self{
        .flags = null,
        .editor_window = null,
        .buf = undefined,
    };

    self.flags = imgui.ImGuiWindowFlags_None;
    self.editor_window = imgui.MemoryEditor_MemoryEditor();
    self.buf[0] = 1;

    return self;
}

pub fn draw(self: *Self) void {
    imgui.MemoryEditor_DrawWindow(self.editor_window, "mem edit", &self.buf, self.buf.len, 0);
}

