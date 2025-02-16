const std = @import("std");
const vec3 = @import("vec3.zig");
const color = @import("color.zig");
const ray = @import("ray.zig");

fn hit_sphere(center: vec3.Point3, radius: f64, r: ray.Ray) f64 {
    const oc = vec3.subtract(center, r.origin());
    const a = r.direction().lengthSquared();
    const h = vec3.dotProduct(r.direction(), oc);
    const c = oc.lengthSquared() - (radius * radius);
    const discriminant = (h * h) - (a * c);

    return if (discriminant < 0) -1.0 else (h - std.math.sqrt(discriminant)) / a;
}

fn ray_color(r: ray.Ray) color.Color {
    const t = hit_sphere(vec3.Point3{ .e = [3]f64{ 0, 0, -1 } }, 0.5, r);
    if (t > 0.0) {
        const N = vec3.unitVector(
            vec3.subtract(
                r.at(t),
                vec3.Vec3{ .e = [3]f64{ 0, 0, -1 } },
            ),
        );
        return vec3.multiplyScalarByVector(
            0.5,
            color.Color{ .e = [3]f64{ N.x() + 1, N.y() + 1, N.z() + 1 } },
        );
    }

    const unit_direction = vec3.unitVector(r.direction());
    const a = 0.5 * (unit_direction.y() + 1.0);
    return vec3.add(
        vec3.multiplyScalarByVector((1.0 - a), color.Color{ .e = [3]f64{ 1.0, 1.0, 1.0 } }),
        vec3.multiplyScalarByVector(a, color.Color{ .e = [3]f64{ 0.5, 0.7, 1.0 } }),
    );
}

pub fn main() !void {
    // image
    const aspect_ratio: f64 = 16.0 / 9.0;
    const image_width = 400;
    const calc_image_height = @as(i32, @intFromFloat(image_width / aspect_ratio));
    const image_height = if (calc_image_height < 1) 1 else calc_image_height;
    std.debug.print("Image size: {d}x{d}\n", .{ image_width, image_height });

    // camera
    const focal_length = 1.0;
    const viewport_height = 2.0;
    const viewport_width = viewport_height * (@as(f64, @floatFromInt(image_width)) / image_height);
    const camera_center = vec3.Point3{};

    // vectors across horizontal and down the veritcal viewport edges
    const viewport_u = vec3.Vec3{ .e = [3]f64{ viewport_width, 0, 0 } };
    const viewport_v = vec3.Vec3{ .e = [3]f64{ 0, -viewport_height, 0 } };

    // horizontal and vertical delta vectors from pixel to pixel
    const pixel_delta_u = vec3.divide(viewport_u, image_width);
    const pixel_delta_v = vec3.divide(viewport_v, image_height);

    // get location of upper left pixel
    const viewport_upper_left = vec3.subtract(
        vec3.subtract(
            vec3.subtract(
                camera_center,
                vec3.Vec3{ .e = [3]f64{ 0, 0, focal_length } },
            ),
            vec3.divide(viewport_u, 2),
        ),
        vec3.divide(viewport_v, 2),
    );
    const pixel00_loc = vec3.add(
        viewport_upper_left,
        vec3.multiplyScalarByVector(
            0.5,
            vec3.add(pixel_delta_u, pixel_delta_v),
        ),
    );

    const stdout = std.io.getStdOut().writer();
    try stdout.print("P3\n{d} {d}\n255\n", .{ image_width, image_height });

    for (0..image_height) |j| {
        std.log.info("\rScanlines remaining: {d}", .{image_height - j - 1});
        for (0..image_width) |i| {
            const pixel_center = vec3.add(
                vec3.add(
                    pixel00_loc,
                    vec3.multiplyScalarByVector(@as(f64, @floatFromInt(i)), pixel_delta_u),
                ),
                vec3.multiplyScalarByVector(@as(f64, @floatFromInt(j)), pixel_delta_v),
            );
            const ray_direction = vec3.subtract(pixel_center, camera_center);
            const r = ray.Ray{
                ._orig = camera_center,
                ._dir = ray_direction,
            };
            const pixel_color = ray_color(r);
            try color.write_color(pixel_color);
        }
    }

    std.log.info("\rDone.\n", .{});
}
