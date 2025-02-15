const std = @import("std");

pub fn main() !void {
    const image_width = 256;
    const image_height = 256;

    const stdout = std.io.getStdOut().writer();
    try stdout.print("P3\n{d} {d}\n255\n", .{ image_width, image_height });

    for (0..image_height) |j| {
        std.log.info("\rScanlines remaining: {d}", .{image_height - j - 1});
        for (0..image_width) |i| {
            const r = @as(f64, @floatFromInt(i)) / (image_width - 1);
            const g = @as(f64, @floatFromInt(j)) / (image_height - 1);
            const b = 0.0;

            const ir: i32 = @intFromFloat(255.999 * r);
            const ig: i32 = @intFromFloat(255.999 * g);
            const ib: i32 = @intFromFloat(255.999 * b);

            try stdout.print("{d} {d} {d}\n", .{ ir, ig, ib });
        }
    }

    std.log.info("\rDone.\n", .{});
}
