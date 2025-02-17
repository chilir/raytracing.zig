// src/main.zig

const std = @import("std");

const vec3 = @import("vec3.zig");
const color = @import("color.zig");
const ray = @import("ray.zig");
const hittable = @import("hittable.zig");
const interval = @import("interval.zig");
const camera = @import("camera.zig");

const Vec3 = vec3.Vec3;
const Point3 = vec3.Point3;
const Color = color.Color;
const Ray = ray.Ray;
const HitRecord = hittable.HitRecord;
const Hittable = hittable.Hittable;
const Sphere = hittable.Sphere;
const HittableList = hittable.HittableList;
const Interval = interval.Interval;
const Camera = camera.Camera;

// some math utils
const pi = std.math.pi;

inline fn degrees_to_radians(degrees: f64) f64 {
    return degrees * (pi / 180.0);
}

pub fn main() !void {
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

    var cam = Camera{
        .aspect_ratio = 16.0 / 9.0,
        .image_width = 400,
        .samples_per_pixel = 100,
    };
    try cam.render(&world);
}
