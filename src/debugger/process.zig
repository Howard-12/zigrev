const std = @import("std");
const fs = std.fs;

const Self = @This();

const proc_path = "/proc";

process_id: u32,
memory_buffer: ?[]u8,

pub fn init() Self {
    const self = Self{
        .memory_buffer = null,
        .process_id = 0,
    };

    return self;
}


// Might consider store the result as struct member in the future.
pub fn enumerate_processes(self: *Self, allocator: std.mem.Allocator) ![]const [*:0]const u8 {
    _ = self;
    var dirs: fs.Dir = try fs.openDirAbsoluteZ(proc_path, .{ .iterate = true });
    defer dirs.close();

    var dir_iter = dirs.iterate();

    var pids = try std.ArrayList([*:0]const u8).initCapacity(allocator, 100);
    while (try dir_iter.next()) |dir| {
        if (is_pid(dir.name)) {
            const ownd = try allocator.dupeZ(u8, dir.name);
            try pids.append(allocator, ownd);
        }
    }

    return try pids.toOwnedSlice(allocator);
}

pub fn get_pid(target: []u8) u32 {
    _ = target;
}

pub fn deinit(self: *Self) void {
    _ = self;
}


pub fn set_current_active_process(self: *Self, pid: u32) void {
    self.process_id = pid;
}

pub fn attach_to_gdb() !void {
    
}

fn is_pid(dir: []const u8) bool {
    for (dir) |d| {
        if (!std.ascii.isDigit(d)) return false;
    }
    return dir.len > 0;
}
