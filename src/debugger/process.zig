const std = @import("std");

const Self = @This();

allocator: std.mem.Allocator,
process_id: u32,
memory_buffer: []u8,

pub fn init(allocator: std.mem.Allocator) Self {
    var self = Self {
        .memory_buffer = undefined,
        .process_id = undefined,
        .allocator = allocator,
    };

    self.memory_buffer = self.allocator.alloc(u8, 100) catch |err| {

        std.debug.print("{}", .{err});
        std.os.linux.exit(1);
    };

    self.memory_buffer[99] = 0x10;
    for (0..self.memory_buffer.len) |l| {
        self.memory_buffer[l] = 0x33;
        
    }

    return self;
}

pub fn get_pid(target: []u8) u32 {

    _ = target;
}

fn enumerate_processes(self: *Self) u32 {

    self.memory_buffer[0] = 0x10;
    
    return 0;
}

pub fn deinit() void {

}
