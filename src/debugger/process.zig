const std = @import("std");

const Self = @This();

allocator: std.mem.Allocator,
process_id: u32,
memory_buffer: ?[]u8,

pub fn init(allocator: std.mem.Allocator) !Self {
    const self = Self {
        .memory_buffer = null,
        .process_id = 0,
        .allocator = allocator,
    };

    return self;
}

pub fn get_pid(target: []u8) u32 {
    _ = target;
}

fn enumerate_processes(_: *Self) u32 {
    
    return 0;
}

pub fn deinit() void {

}
