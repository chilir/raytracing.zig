// src/main.zig

const std = @import("std");

const vec3 = @import("vec3.zig");
const color = @import("color.zig");
const ray = @import("ray.zig");
const hittable = @import("hittable.zig");

const Vec3 = vec3.Vec3;
const Point3 = vec3.Point3;
const Color = color.Color;
const Ray = ray.Ray;
const HitRecord = hittable.HitRecord;
const Hittable = hittable.Hittable;
const Sphere = hittable.Sphere;
const HittableList = hittable.HittableList;

// some math utils
const infinity = std.math.inf(f64);
const pi = std.math.pi;

inline fn degrees_to_radians(degrees: f64) f64 {
    return degrees * (pi / 180.0);
}

fn ray_color(r: Ray, world: *const HittableList) Color {
    var rec = HitRecord{};

    if (world.hit(r, 0, infinity, &rec)) {
        return vec3.multiplyScalarByVector(
            0.5,
            vec3.add(rec.normal, Color.init(1, 1, 1)),
        );
    }

    const unit_direction = vec3.unitVector(r.direction());
    const a = 0.5 * (unit_direction.y() + 1.0);
    return vec3.add(
        vec3.multiplyScalarByVector((1.0 - a), Color.init(1.0, 1.0, 1.0)),
        vec3.multiplyScalarByVector(a, Color.init(0.5, 0.7, 1.0)),
    );
}

pub fn main() !void {
    // image
    const aspect_ratio: f64 = 16.0 / 9.0;
    const image_width = 400;
    const calc_image_height = @as(i32, @intFromFloat(image_width / aspect_ratio));
    const image_height = if (calc_image_height < 1) 1 else calc_image_height;

    // world
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var world = try HittableList.init(
        Hittable{
            .sphere = Sphere.init(
                Point3.init(0, 0, -1),
                0.5,
            ),
        },
        allocator,
    );
    defer world.deinit();
    try world.add(
        Hittable{
            .sphere = Sphere.init(
                Point3.init(0, -100.5, -1),
                100,
            ),
        },
    );

    // camera
    const focal_length = 1.0;
    const viewport_height = 2.0;
    const viewport_width = viewport_height * (@as(f64, @floatFromInt(image_width)) / image_height);
    const camera_center = Point3{};

    // vectors across horizontal and down the veritcal viewport edges
    const viewport_u = Vec3.init(viewport_width, 0, 0);
    const viewport_v = Vec3.init(0, -viewport_height, 0);

    // horizontal and vertical delta vectors from pixel to pixel
    const pixel_delta_u = vec3.divide(viewport_u, image_width);
    const pixel_delta_v = vec3.divide(viewport_v, image_height);

    // get location of upper left pixel
    const viewport_upper_left = vec3.subtract(
        vec3.subtract(
            vec3.subtract(
                camera_center,
                Vec3.init(0, 0, focal_length),
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
            const r = Ray.init(camera_center, ray_direction);
            const pixel_color = ray_color(r, &world);
            try color.write_color(pixel_color);
        }
    }

    std.log.info("\rDone.\n", .{});
}
