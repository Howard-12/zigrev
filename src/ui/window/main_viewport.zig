const std = @import("std");
const imgui = @import("root").zigrev.c;

const Self = @This();

flags: ?imgui.ImGuiWindowFlags,

pub fn init() Self {
    var self = Self{
        .flags = null,
    };

    self.flags = imgui.ImGuiWindowFlags_NoTitleBar;
    // self.flags.? |= imgui.ImGuiWindowFlags_NoMove;

    return self;
}

pub fn draw(self: *Self) void {

    // centring
    // const center = imgui.ImGuiViewport_GetCenter(imgui.ImGui_GetMainViewport());
    // imgui.ImGui_SetNextWindowPosEx(center, imgui.ImGuiCond_Always, imgui.ImVec2_t{.x = 0.5, .y = 0.5});

    _ = imgui.ImGui_Begin("hi window", null, self.flags.?);
    imgui.ImGui_Text("text 00");
    imgui.ImGui_End();
}
