const std = @import("std");
const imgui = @import("root").zigrev.c;

const Self = @This();

flags: ?imgui.ImGuiWindowFlags,

pub fn init() Self {
    var self = Self{
        .flags = null,
    };

    self.flags = imgui.ImGuiWindowFlags_None;

    return self;
}

pub fn draw(self: *Self) void {
    _ = imgui.ImGui_Begin("main window", null, self.flags.?);
    imgui.ImGui_Text("content here");
    imgui.ImGui_End();
}
