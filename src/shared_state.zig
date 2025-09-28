const std = @import("std");
pub const Process = @import("debugger/process.zig");

const Self = @This();

allocator: std.mem.Allocator,
process: Process,

// TODO: add functions here to update states like a control

pub fn init(allocator: std.mem.Allocator) !Self {
    var self = Self {
        .allocator = allocator,
        .process = undefined, 
    };

    self.process = Process.init();

    return self;
}

pub fn setProcessMemorybuf(self: *Self, data: []const u8) !void {
    self.process.memory_buffer = try self.allocator.alloc(u8, data.len);
    if (self.process.memory_buffer) |buf| {
        @memcpy(buf, data);
    }
}

pub fn clean(self: *Self) void {

    self.process.deinit();
}


pub fn readMem(self: *Self) !void {
    _ = self;
    // TODO: read mem
    // std.os.linux.process_vm_readv(pid: i32, local: []const iovec, remote: []const iovec_const, flags: usize)
    // and set process.memory_buffer

}
