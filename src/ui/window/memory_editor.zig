const std = @import("std");
const zigrev = @import("root").zigrev;
const imgui = zigrev.c;
const SharedState = zigrev.SharedState;

const Self = @This();

flags: ?imgui.ImGuiWindowFlags,
editor_window: ?*imgui.MemoryEditor,
default_buf: [100]u8,
show_window: bool = true,

pub fn init() Self {
    var self = Self{
        .flags = null,
        .editor_window = null,
        .default_buf = undefined,
    };

    self.flags = imgui.ImGuiWindowFlags_None;
    self.editor_window = imgui.MemoryEditor_MemoryEditor();
    self.default_buf = .{0} ** 100;

    return self;
}

pub fn update(self: *Self, state: *SharedState) void{
    if (!self.show_window) 
        return;

    _ = state;
}

pub fn draw(self: *Self, state: *SharedState) void {
    if (!self.show_window) 
        return;

    if (state.*.process.memory_buffer) |*buf| {
        imgui.MemoryEditor_DrawWindow(self.editor_window, "mem edit", buf.ptr, buf.len, 0);
    } else {
        imgui.MemoryEditor_DrawWindow(self.editor_window, "mem edit", &self.default_buf, self.default_buf.len, 0);
    }
        
}


pub fn deinit(_: *Self) void {

}
