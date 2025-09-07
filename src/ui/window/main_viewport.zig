const std = @import("std");
const zigrev = @import("root").zigrev;
const imgui = zigrev.c;
const GlobalState = zigrev.GlobalState;

const Self = @This();

flags: ?imgui.ImGuiWindowFlags,

pub fn init() Self {
    var self = Self{
        .flags = null,
    };

    self.flags = imgui.ImGuiWindowFlags_None;

    return self;
}

pub fn update(self: *Self, state: *GlobalState) void{
    _ = self;
    _ = state;
}

pub fn draw(self: *Self, state: *GlobalState) void {
    _ = state;
    _ = imgui.ImGui_Begin("main window", null, self.flags.?);
    imgui.ImGui_Text("content here");
    imgui.ImGui_End();
}

pub fn deinit(_: *Self) void {
    
}
