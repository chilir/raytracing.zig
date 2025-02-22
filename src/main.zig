// src/main.zig

const std = @import("std");

const vec3 = @import("vec3.zig");
const hittable = @import("hittable.zig");
const material = @import("material.zig");

const Vec3 = vec3.Vec3;
const Point3 = vec3.Point3;
const Color = @import("color.zig").Color;
const Ray = @import("ray.zig").Ray;
const HitRecord = hittable.HitRecord;
const Hittable = hittable.Hittable;
const Sphere = hittable.Sphere;
const HittableList = hittable.HittableList;
const Interval = @import("interval.zig").Interval;
const Camera = @import("camera.zig").Camera;
const Material = material.Material;
const Lambertian = material.Lambertian;
const Metal = material.Metal;

// some math utils

pub fn main() !void {
    const material_ground = Material{ .lambertian = Lambertian.init(Color.init(0.8, 0.8, 0)) };
    const material_center = Material{ .lambertian = Lambertian.init(Color.init(0.1, 0.2, 0.5)) };
    const material_left = Material{ .metal = Metal.init(Color.init(0.8, 0.8, 0.8), 0.3) };
    const material_right = Material{ .metal = Metal.init(Color.init(0.8, 0.6, 0.2), 1.0) };

    // world
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var world = try HittableList.init(
        Hittable{ .sphere = Sphere.init(Point3.init(0, -100.5, -1), 100, material_ground) },
        allocator,
    );
    defer world.deinit();

    try world.add(
        Hittable{ .sphere = Sphere.init(Point3.init(0, 0, -1.2), 0.5, material_center) },
    );
    try world.add(
        Hittable{ .sphere = Sphere.init(Point3.init(-1, 0, -1), 0.5, material_left) },
    );
    try world.add(
        Hittable{ .sphere = Sphere.init(Point3.init(1, 0, -1), 0.5, material_right) },
    );

    var cam = Camera{
        .aspect_ratio = 16.0 / 9.0,
        .image_width = 400,
        .samples_per_pixel = 100,
        .max_depth = 50,
    };
    try cam.render(&world);
}
