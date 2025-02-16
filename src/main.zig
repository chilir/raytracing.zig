const std = @import("std");
const color = @import("color.zig");

pub fn main() !void {
    const image_width = 256;
    const image_height = 256;

    const stdout = std.io.getStdOut().writer();
    try stdout.print("P3\n{d} {d}\n255\n", .{ image_width, image_height });

    for (0..image_height) |j| {
        std.log.info("\rScanlines remaining: {d}", .{image_height - j - 1});
        for (0..image_width) |i| {
            const pixel_color = color.Color{
                .e = [3]f64{
                    @as(f64, @floatFromInt(i)) / (image_width - 1),
                    @as(f64, @floatFromInt(j)) / (image_height - 1),
                    0,
                },
            };
            try color.write_color(pixel_color);
        }
    }

    std.log.info("\rDone.\n", .{});
}
