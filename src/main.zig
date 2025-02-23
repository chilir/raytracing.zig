// src/main.zig

const std = @import("std");

const vec3 = @import("vec3.zig");
const hittable = @import("hittable.zig");
const material = @import("material.zig");
const utils = @import("utils.zig");

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
const Dielectric = material.Dielectric;

pub fn main() !void {
    const ground_material = Material{ .lambertian = Lambertian.init(Color.init(0.5, 0.5, 0.5)) };

    // world
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var world = try HittableList.init(
        Hittable{ .sphere = Sphere.init(Point3.init(0, -1000, 0), 1000, ground_material) },
        allocator,
    );
    defer world.deinit();

    for (0..22) |a_unsigned| {
        const a = @as(i32, @intCast(a_unsigned)) - 11;
        for (0..22) |b_unsigned| {
            const b = @as(i32, @intCast(b_unsigned)) - 11;
            const choose_mat = utils.randomFloat();
            const center = Point3.init(
                @as(f64, @floatFromInt(a)) + 0.9 * utils.randomFloat(),
                0.2,
                @as(f64, @floatFromInt(b)) + 0.9 * utils.randomFloat(),
            );

            var sphere_material: Material = undefined;
            if (vec3.subtract(center, Point3.init(4, 0.2, 0)).length() > 0.9) {
                if (choose_mat < 0.8) {
                    // diffuse
                    const albedo = vec3.elementWiseProduct(Color.random(), Color.random());
                    sphere_material = Material{ .lambertian = Lambertian.init(albedo) };
                    try world.add(Hittable{ .sphere = Sphere.init(center, 0.2, sphere_material) });
                } else if (choose_mat < 0.95) {
                    // metal
                    const albedo = Color.randomFromRange(0.5, 1);
                    const fuzz = utils.randomFloatFromRange(0, 0.5);
                    sphere_material = Material{ .metal = Metal.init(Color.init(albedo.x(), albedo.y(), albedo.z()), fuzz) };
                    try world.add(Hittable{ .sphere = Sphere.init(center, 0.2, sphere_material) });
                } else {
                    // glass
                    sphere_material = Material{ .dielectric = Dielectric.init(1.5) };
                    try world.add(Hittable{ .sphere = Sphere.init(center, 0.2, sphere_material) });
                }
            }
        }
    }

    const material1 = Material{ .dielectric = Dielectric.init(1.5) };
    try world.add(Hittable{ .sphere = Sphere.init(Point3.init(0, 1, 0), 1.0, material1) });

    const material2 = Material{ .lambertian = Lambertian.init(Color.init(0.4, 0.2, 0.1)) };
    try world.add(Hittable{ .sphere = Sphere.init(Point3.init(-4, 1, 0), 1.0, material2) });

    const material3 = Material{ .metal = Metal.init(Color.init(0.7, 0.6, 0.5), 0.0) };
    try world.add(Hittable{ .sphere = Sphere.init(Point3.init(4, 1, 0), 1.0, material3) });

    var cam = Camera{
        .aspect_ratio = 16.0 / 9.0,
        .image_width = 1200,
        .samples_per_pixel = 500,
        .max_depth = 50,
        .vfov = 20,
        .lookfrom = Point3.init(13, 2, 3),
        .lookat = .{},
        .vup = Vec3.init(0, 1, 0),
        .defocus_angle = 0.6,
        .focus_dist = 10.0,
    };
    try cam.render(&world);
}
