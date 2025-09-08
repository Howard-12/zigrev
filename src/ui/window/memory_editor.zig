const std = @import("std");
const zigrev = @import("root").zigrev;
const imgui = zigrev.c;
const SharedState = zigrev.SharedState;

const Self = @This();

flags: ?imgui.ImGuiWindowFlags,
editor_window: ?*imgui.MemoryEditor,
buf: [256]u8,
show_window: bool = true,

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

pub fn update(self: *Self, state: *SharedState) void{
    // if (!self.show_window) return;
    _ = self;
    _ = state;
}

pub fn draw(self: *Self, state: *SharedState) void {
    // if (!self.show_window) return;
    imgui.MemoryEditor_DrawWindow(self.editor_window, "mem edit", state.process.memory_buffer.ptr, state.process.memory_buffer.len, 0);
}


pub fn deinit(_: *Self) void {

}
