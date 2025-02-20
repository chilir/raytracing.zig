// src/camera.zig

const std = @import("std");

const vec3 = @import("vec3.zig");
const color = @import("color.zig");
const hittable = @import("hittable.zig");
const utils = @import("utils.zig");

const Vec3 = vec3.Vec3;
const Point3 = vec3.Point3;
const Color = color.Color;
const Ray = @import("ray.zig").Ray;
const HitRecord = hittable.HitRecord;
const Hittable = hittable.Hittable;
const HittableList = hittable.HittableList;
const Interval = @import("interval.zig").Interval;

pub const Camera = struct {
    aspect_ratio: f64 = 1.0,
    image_width: usize = 100,
    samples_per_pixel: usize = 10,
    max_depth: usize = 10,

    _image_height: usize = 1,
    _pixel_samples_scale: f64 = 1.0,
    _center: Point3 = Point3{},
    _pixel00_loc: Point3 = Point3{},
    _pixel_delta_u: Vec3 = Vec3{},
    _pixel_delta_v: Vec3 = Vec3{},

    fn initialize(self: *Camera) void {
        // calc image height
        const height_float = @as(f64, @floatFromInt(self.image_width)) / self.aspect_ratio;
        self._image_height = if (height_float < 1) 1 else @intFromFloat(height_float);

        self._pixel_samples_scale = 1.0 / @as(f64, @floatFromInt(self.samples_per_pixel));

        // camera
        const focal_length = 1.0;
        const viewport_height = 2.0;
        const viewport_width = viewport_height * (@as(f64, @floatFromInt(self.image_width)) /
            @as(f64, @floatFromInt(self._image_height)));

        // vectors across horizontal and down the veritcal viewport edges
        const viewport_u = Vec3.init(viewport_width, 0, 0);
        const viewport_v = Vec3.init(0, -viewport_height, 0);

        // horizontal and vertical delta vectors from pixel to pixel
        self._pixel_delta_u = vec3.divide(viewport_u, @as(f64, @floatFromInt(self.image_width)));
        self._pixel_delta_v = vec3.divide(viewport_v, @as(f64, @floatFromInt(self._image_height)));

        // get location of upper left pixel
        const viewport_upper_left = vec3.subtract(
            vec3.subtract(
                vec3.subtract(
                    self._center,
                    Vec3.init(0, 0, focal_length),
                ),
                vec3.divide(viewport_u, 2),
            ),
            vec3.divide(viewport_v, 2),
        );
        self._pixel00_loc = vec3.add(
            viewport_upper_left,
            vec3.multiplyScalarByVector(
                0.5,
                vec3.add(self._pixel_delta_u, self._pixel_delta_v),
            ),
        );
    }

    fn sampleSquare() Vec3 {
        return Vec3.init(utils.randomFloat() - 0.5, utils.randomFloat() - 0.5, 0);
    }

    fn getRay(self: Camera, i: usize, j: usize) Ray {
        const offset = sampleSquare();
        const pixel_sample = vec3.add(
            vec3.add(
                self._pixel00_loc,
                vec3.multiplyScalarByVector(
                    @as(f64, @floatFromInt(i)) + offset.x(),
                    self._pixel_delta_u,
                ),
            ),
            vec3.multiplyScalarByVector(
                @as(f64, @floatFromInt(j)) + offset.y(),
                self._pixel_delta_v,
            ),
        );

        const ray_origin = self._center;
        const ray_direction = vec3.subtract(pixel_sample, ray_origin);

        return Ray.init(ray_origin, ray_direction);
    }

    fn rayColor(r: Ray, depth: usize, world: *const HittableList) Color {
        if (depth <= 0) {
            return Color{};
        }

        var rec = HitRecord{};

        if (world.hit(r, Interval.init(0.001, utils.infinity), &rec)) {
            var scattered = Ray{};
            var attenuation = Color{};
            if (rec.mat.scatter(r, rec, &attenuation, &scattered)) {
                return vec3.elementWiseProduct(attenuation, rayColor(scattered, depth - 1, world));
            }
            // const direction = vec3.add(rec.normal, vec3.randomUnitVector());
            // return vec3.multiplyScalarByVector(
            //     0.5,
            //     rayColor(Ray.init(rec.p, direction), depth - 1, world),
            // );
        }

        const unit_direction = vec3.unitVector(r.direction());
        const a = 0.5 * (unit_direction.y() + 1.0);
        return vec3.add(
            vec3.multiplyScalarByVector((1.0 - a), Color.init(1.0, 1.0, 1.0)),
            vec3.multiplyScalarByVector(a, Color.init(0.5, 0.7, 1.0)),
        );
    }

    pub fn render(self: *Camera, world: *const HittableList) !void {
        initialize(self);

        const stdout = std.io.getStdOut().writer();
        try stdout.print("P3\n{d} {d}\n255\n", .{ self.image_width, self._image_height });

        for (0..self._image_height) |j| {
            std.log.info("\rScanlines remaining: {d}", .{self._image_height - j - 1});
            for (0..self.image_width) |i| {
                var pixel_color = Color{};
                for (0..self.samples_per_pixel) |_| {
                    const r = self.getRay(i, j);
                    pixel_color.addInPlace(rayColor(r, self.max_depth, world));
                }
                try color.writeColor(
                    vec3.multiplyScalarByVector(self._pixel_samples_scale, pixel_color),
                );
            }
        }

        std.log.info("\rDone.\n", .{});
    }
};
