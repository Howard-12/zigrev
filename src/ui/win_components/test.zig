const std = @import("std");
const imgui = @import("root").zigrev.c;

const Self = @This();

flags: ?imgui.ImGuiWindowFlags,

pub fn init() Self {
    var self = Self{
        .flags = null,
    };

    self.flags = imgui.ImGuiWindowFlags_NoTitleBar;
    self.flags |= imgui.ImGuiWindowFlags_NoMove;

    return self;
}

pub fn draw(self: *Self) void {
    _ = imgui.ImGui_Begin("hi window", null, self.flags.?);
    imgui.ImGui_Text("text 00");
    imgui.ImGui_End();
}
