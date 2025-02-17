// src/color.zig

const std = @import("std");
const vec3 = @import("vec3.zig");
const interval = @import("interval.zig");

const Interval = interval.Interval;

pub const Color = vec3.Vec3;

pub fn write_color(pixel_color: Color) !void {
    const r = pixel_color.x();
    const g = pixel_color.y();
    const b = pixel_color.z();

    const intensity = Interval.init(0.000, 0.999);
    const rbyte: i32 = @intFromFloat(256 * intensity.clamp(r));
    const gbyte: i32 = @intFromFloat(256 * intensity.clamp(g));
    const bbyte: i32 = @intFromFloat(256 * intensity.clamp(b));

    const stdout = std.io.getStdOut().writer();
    try stdout.print("{d} {d} {d}\n", .{ rbyte, gbyte, bbyte });
}
