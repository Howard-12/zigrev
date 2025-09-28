const std = @import("std");
const fs = std.fs;
const pid_t = std.os.linux.pid_t;
const Self = @This();
const linux = std.os.linux;

const proc_path = "/proc";

pub const ProcessError = error {
    FailedToAttachToProcess,
};

process_id: pid_t,
memory_buffer: ?[]u8,

pub fn init() Self {
    const self = Self{
        .memory_buffer = null,
        .process_id = 0,
    };

    std.debug.print("[*] Local pid: {d}\n", .{ getLocalProcessPid() });

    return self;
}


// Might consider store the result as struct member in the future.
pub fn enumerateProcesses(self: *Self, allocator: std.mem.Allocator) ![]const [*:0]const u8 {
    _ = self;
    var dirs: fs.Dir = try fs.openDirAbsoluteZ(proc_path, .{ .iterate = true });
    defer dirs.close();

    var dir_iter = dirs.iterate();

    var pids = try std.ArrayList([*:0]const u8).initCapacity(allocator, 100);
    while (try dir_iter.next()) |dir| {
        if (isPid(dir.name)) {
            const ownd = try allocator.dupeZ(u8, dir.name);
            try pids.append(allocator, ownd);
        }
    }

    return try pids.toOwnedSlice(allocator);
}

pub fn getPid(target: []u8) u32 {
    _ = target;
}

pub fn deinit(self: *Self) void {
    _ = self;
}


pub fn setCurrentActiveProcess(self: *Self, pid: pid_t) void {
    self.process_id = pid;
}

pub fn attachToGdb() !void {
    
}

/// use ptrace syscall to attach the process
/// TODO: i think i need to spawn a new thread
pub fn attachToPid(self: *Self) !void {
    const ret = linux.ptrace(linux.PTRACE.ATTACH, self.process_id, 0, 0, 0);
    if (ret != 0)
        return ProcessError.FailedToAttachToProcess;

    std.debug.print("[*] Attached: {d}\n", .{ret});

    var status: u32 = 0;
    const wpid = linux.waitpid(self.process_id, &status, 0);
    std.debug.print("wpid: {b}\n", .{wpid & 0xff});

    // if spawn thread, need to store thread id?
    // can i do seek mem in different function?
}


pub fn getLocalProcessPid() std.os.linux.pid_t {
    return linux.getpid();
}

fn isPid(dir: []const u8) bool {
    for (dir) |d| {
        if (!std.ascii.isDigit(d)) return false;
    }
    return dir.len > 0;
}
