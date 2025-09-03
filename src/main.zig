const std = @import("std");

pub const zigrev = @import("zigrev.zig");

pub fn main() !void {
    const config: zigrev.Config = .{};

    var rev = try zigrev.setup(config);
    defer rev.clean();

    rev.run();
}
