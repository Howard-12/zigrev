const std = @import("std");
const zigrev = @import("root").zigrev;
const imgui = zigrev.c;
const SharedState = zigrev.SharedState;

const Self = @This();

flags: ?imgui.ImGuiWindowFlags,
request_update: bool = true, 

pid_buf: ?[]const [*:0]const u8,
exe_path_buf: [256:0]u8,
selected_pid: [16:0]u8,
current_item: c_int = 1,

valid_pid: bool = true,

pub fn init() Self {
    var self = Self{
        .flags = null,
        .pid_buf = null,
        .selected_pid = undefined,
        .exe_path_buf = undefined,
    };

    self.flags = imgui.ImGuiWindowFlags_None;

    self.selected_pid = .{0} ** 16;
    self.exe_path_buf = .{0} ** 256;

    return self;
}

pub fn update(self: *Self, state: *SharedState) !void{
    if (self.request_update) {
        self.pid_buf = try state.process.enumerateProcesses(state.allocator);

        self.request_update = false;
    }
}

pub fn draw(self: *Self, state: *SharedState) !void {
    // _ = state;
    _ = imgui.ImGui_Begin("main window", null, self.flags.?);

    // spawn a process and attach it 
    imgui.ImGui_SeparatorText("Launch program");
    if (imgui.ImGui_InputText("Executable path", &self.exe_path_buf, self.exe_path_buf.len, imgui.ImGuiInputTextFlags_None)) {

    }

    // Attach a running process
    imgui.ImGui_SeparatorText("Attach pid");
    if (imgui.ImGui_InputTextEx("##", &self.selected_pid, self.selected_pid.len, imgui.ImGuiInputTextFlags_CallbackCharFilter, Self.alphabetFilter, null)) {}
    imgui.ImGui_SameLine();
    if (imgui.ImGui_Button("Attach")) {
        if (self.selected_pid[0] > 0) { // User input is a char
            std.debug.print("selected pid: {s}\n", .{self.selected_pid});
            state.process.setCurrentActiveProcess(try std.fmt.parseInt(i32, self.selected_pid[0..std.mem.len(@as([*:0]u8 ,@ptrCast(&self.selected_pid)))], 10));
            if (state.process.attachToPid()) {
                self.valid_pid = true;
            } else |err| switch (err) {
                SharedState.Process.ProcessError.FailedToAttachToProcess => self.valid_pid = false,
                SharedState.Process.ProcessError.ProcessIdCanNotBeZero => self.valid_pid = false,
            }
                
        } else 
            self.valid_pid = false;
    }

    // Show error message if the input is:
    // - Empty
    // - Not a process
    if (!self.valid_pid) {
        imgui.ImGui_SameLine();
        imgui.ImGui_Text("Error: Can not attach to pid or field is empty");
    }

    // Scan processes
    if (imgui.ImGui_Button("Scan processes"))
        self.request_update = true;

    // TODO: Use table with column of pid and name, similar to top
    if (imgui.ImGui_ListBox("pids", 
                            &self.current_item, 
                            &self.pid_buf.?[0],
                            @intCast(self.pid_buf.?.len), 
                            10)) {
        // std.debug.print("selected index = {}\n", .{self.current_item});
        @memcpy(self.selected_pid[0..], self.pid_buf.?[@intCast(self.current_item)]);
    }

    imgui.ImGui_End();
}

pub fn deinit(self: *Self, state: *SharedState) void {
    if (self.pid_buf) |buf|
        state.allocator.free(buf);
}

pub fn alphabetFilter(data: [*c]imgui.ImGuiInputTextCallbackData) callconv(.c) c_int {
    const current_char = data.*.EventChar;
    if (current_char >= '0' and current_char <= '9')
        return 0;

    data.*.EventChar = 0;
    return 1;
}
