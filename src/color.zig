// src/color.zig

const std = @import("std");

const vec3 = @import("vec3.zig");

const Interval = @import("interval.zig").Interval;

pub const Color = vec3.Vec3;

inline fn linearToGamma(linear_component: f64) f64 {
    if (linear_component > 0.0) {
        return std.math.sqrt(linear_component);
    }

    return 0.0;
}

pub fn writeColor(pixel_color: Color) !void {
    var r = pixel_color.x();
    var g = pixel_color.y();
    var b = pixel_color.z();

    r = linearToGamma(r);
    g = linearToGamma(g);
    b = linearToGamma(b);

    const intensity = Interval.init(0.000, 0.999);
    const rbyte: i32 = @intFromFloat(256.0 * intensity.clamp(r));
    const gbyte: i32 = @intFromFloat(256.0 * intensity.clamp(g));
    const bbyte: i32 = @intFromFloat(256.0 * intensity.clamp(b));

    const stdout = std.io.getStdOut().writer();
    try stdout.print("{d} {d} {d}\n", .{ rbyte, gbyte, bbyte });
}
