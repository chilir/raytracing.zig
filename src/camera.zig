// src/camera.zig

const std = @import("std");

const vec3 = @import("vec3.zig");
const color = @import("color.zig");
const ray = @import("ray.zig");
const hittable = @import("hittable.zig");
const interval = @import("interval.zig");

const Vec3 = vec3.Vec3;
const Point3 = vec3.Point3;
const Color = color.Color;
const Ray = ray.Ray;
const HitRecord = hittable.HitRecord;
const Hittable = hittable.Hittable;
const HittableList = hittable.HittableList;
const Interval = interval.Interval;

const infinity = std.math.inf(f64);

pub const Camera = struct {
    aspect_ratio: f64 = 1.0,
    image_width: usize = 100,

    _image_height: usize = 1,
    _center: Point3 = Point3{},
    _pixel00_loc: Point3 = Point3{},
    _pixel_delta_u: Vec3 = Vec3{},
    _pixel_delta_v: Vec3 = Vec3{},

    fn initialize(self: *Camera) void {
        // calc image height
        const height_float = @as(f64, @floatFromInt(self.image_width)) / self.aspect_ratio;
        self._image_height = if (height_float < 1) 1 else @intFromFloat(height_float);

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

    pub fn render(self: *Camera, world: *const HittableList) !void {
        initialize(self);

        const stdout = std.io.getStdOut().writer();
        try stdout.print("P3\n{d} {d}\n255\n", .{ self.image_width, self._image_height });

        for (0..self._image_height) |j| {
            std.log.info("\rScanlines remaining: {d}", .{self._image_height - j - 1});
            for (0..self.image_width) |i| {
                const pixel_center = vec3.add(
                    vec3.add(
                        self._pixel00_loc,
                        vec3.multiplyScalarByVector(
                            @as(f64, @floatFromInt(i)),
                            self._pixel_delta_u,
                        ),
                    ),
                    vec3.multiplyScalarByVector(@as(f64, @floatFromInt(j)), self._pixel_delta_v),
                );
                const ray_direction = vec3.subtract(pixel_center, self._center);
                const r = Ray.init(self._center, ray_direction);
                const pixel_color = ray_color(r, world);
                try color.write_color(pixel_color);
            }
        }

        std.log.info("\rDone.\n", .{});
    }

    fn ray_color(r: Ray, world: *const HittableList) Color {
        var rec = HitRecord{};

        if (world.hit(r, Interval.init(0, infinity), &rec)) {
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
};
