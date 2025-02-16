const std = @import("std");
const vec3 = @import("vec3.zig");

pub const Color = vec3.Vec3;

pub fn write_color(pixel_color: Color) !void {
    const r = pixel_color.x;
    const g = pixel_color.y;
    const b = pixel_color.z;

    const rbyte: i32 = @intFromFloat(255.999 * r);
    const gbyte: i32 = @intFromFloat(255.999 * g);
    const bbyte: i32 = @intFromFloat(255.999 * b);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("{d} {d} {d}\n", .{ rbyte, gbyte, bbyte });
}
