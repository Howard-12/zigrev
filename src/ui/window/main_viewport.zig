const std = @import("std");
const zigrev = @import("root").zigrev;
const imgui = zigrev.c;
const SharedState = zigrev.SharedState;

const Self = @This();

flags: ?imgui.ImGuiWindowFlags,
request_update: bool = true, 
pid_buf: ?[]const []const u8,

pub fn init() Self {
    var self = Self{
        .flags = null,
        .pid_buf = null,
    };

    self.flags = imgui.ImGuiWindowFlags_None;

    return self;
}

pub fn update(self: *Self, state: *SharedState) !void{
    if (self.request_update) {
        self.pid_buf = try state.process.enumerate_processes(state.allocator);

        self.request_update = false;
    }
}

pub fn draw(self: *Self, state: *SharedState) void {
    _ = state;
    _ = imgui.ImGui_Begin("main window", null, self.flags.?);

    if (imgui.ImGui_Button("pids")) {
        self.request_update = true;
    }

    for (self.pid_buf.?) |*pid| {
        imgui.ImGui_Text(@ptrCast(pid.*));
    }

    imgui.ImGui_End();
}

pub fn deinit(self: *Self) void {
    _ = self;
}
