const std = @import("std");
const zigrev = @import("root").zigrev;
const imgui = zigrev.c;
const SharedState = zigrev.SharedState;

const Self = @This();

flags: ?imgui.ImGuiWindowFlags,
request_update: bool = true, 

pid_buf: ?[]const [*:0]const u8,
selected_pid: [16:0]u8,
current_item: c_int = 1,

valid_pid: bool = true,

pub fn init() Self {
    var self = Self{
        .flags = null,
        .pid_buf = null,
        .selected_pid = undefined,
    };

    self.flags = imgui.ImGuiWindowFlags_None;

    self.selected_pid = .{0} ** 16;

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


    imgui.ImGui_SeparatorText("Attach pid");
    if (imgui.ImGui_InputText("##", &self.selected_pid, self.selected_pid.len, imgui.ImGuiInputTextFlags_None)) {
    }
    imgui.ImGui_SameLine();
    if (imgui.ImGui_Button("Attach")) {
        if (self.selected_pid[0] > 0) {
            std.debug.print("selected pid: {s}\n", .{self.selected_pid});
            self.valid_pid = true;
        } else 
            self.valid_pid = false;
    }

    // Show error message if the input is:
    // - Empty
    // - Not a process
    if (!self.valid_pid) {
        imgui.ImGui_SameLine();
        imgui.ImGui_Text("Error: field is empty");
    }

    // Scan processes
    if (imgui.ImGui_Button("Scan processes"))
        self.request_update = true;

    // use table with column of pid and name, similar to top
    if (imgui.ImGui_ListBox("pids", 
                            &self.current_item, 
                            &self.pid_buf.?[0],
                            @intCast(self.pid_buf.?.len), 
                            10) ) {
        std.debug.print("selected index = {}\n", .{self.current_item});
    }

    // for (self.pid_buf.?) |*pid|
    //     imgui.ImGui_Text(@ptrCast(pid.*));

    imgui.ImGui_End();
}

pub fn deinit(self: *Self) void {
    _ = self;
}
