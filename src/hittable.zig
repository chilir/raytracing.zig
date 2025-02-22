// src/hittable.zig

const std = @import("std");

const vec3 = @import("vec3.zig");

const Vec3 = vec3.Vec3;
const Point3 = vec3.Point3;
const Ray = @import("ray.zig").Ray;
const Interval = @import("interval.zig").Interval;
const Material = @import("material.zig").Material;
const Lambertian = @import("material.zig").Lambertian;
const Color = @import("color.zig").Color;

pub const HitRecord = struct {
    // init with placeholder defaults
    p: Point3 = Point3{},
    normal: Vec3 = Vec3{},
    mat: Material = Material{ .lambertian = Lambertian.init(Color{}) },
    t: f64 = 0,
    front_face: bool = false,

    fn setFaceNormal(self: *HitRecord, r: Ray, outward_normal: Vec3) void {
        self.front_face = vec3.dotProduct(r.direction(), outward_normal) < 0;
        self.normal = if (self.front_face) outward_normal else outward_normal.negate();
    }
};

pub const Hittable = union(enum) {
    sphere: Sphere,

    pub fn hit(self: Hittable, r: Ray, ray_t: Interval, rec: *HitRecord) bool {
        return switch (self) {
            .sphere => |s| s.hit(r, ray_t, rec),
        };
    }
};

pub const HittableList = struct {
    objects: std.ArrayList(Hittable),
    allocator: std.mem.Allocator,

    pub fn init(object: Hittable, allocator: std.mem.Allocator) !HittableList {
        var h_list = HittableList{
            .objects = std.ArrayList(Hittable).init(allocator),
            .allocator = allocator,
        };
        try h_list.add(object);
        return h_list;
    }

    pub fn deinit(self: *HittableList) void {
        self.objects.deinit();
    }

    pub fn clear(self: *HittableList) void {
        self.objects.clear();
    }

    pub fn add(self: *HittableList, object: Hittable) !void {
        try self.objects.append(object);
    }

    pub fn hit(self: *const HittableList, r: Ray, ray_t: Interval, rec: *HitRecord) bool {
        var temp_rec = HitRecord{};
        var hit_anything = false;
        var closest_so_far = ray_t.max;

        for (self.objects.items) |object| {
            if (object.hit(r, Interval.init(ray_t.min, closest_so_far), &temp_rec)) {
                hit_anything = true;
                closest_so_far = temp_rec.t;
                rec.* = temp_rec;
            }
        }

        return hit_anything;
    }
};

pub const Sphere = struct {
    _center: Point3,
    _radius: f64,
    _material: Material,

    pub fn init(center: Point3, radius: f64, mat: Material) Sphere {
        return Sphere{
            ._center = center,
            ._radius = @max(0, radius),
            ._material = mat,
        };
    }

    fn hit(self: Sphere, r: Ray, ray_t: Interval, rec: *HitRecord) bool {
        const oc = vec3.subtract(self._center, r.origin());
        const a = r.direction().lengthSquared();
        const h = vec3.dotProduct(r.direction(), oc);
        const c = oc.lengthSquared() - (self._radius * self._radius);

        const discriminant = (h * h) - (a * c);
        if (discriminant < 0) {
            return false;
        }

        const sqrtd = std.math.sqrt(discriminant);

        var root = (h - sqrtd) / a;
        if (!ray_t.surrounds(root)) {
            root = (h + sqrtd) / a;
            if (!ray_t.surrounds(root)) {
                return false;
            }
        }

        rec.t = root;
        rec.p = r.at(rec.t);
        const outward_normal = vec3.divide(vec3.subtract(rec.p, self._center), self._radius);
        rec.setFaceNormal(r, outward_normal);
        rec.mat = self._material;

        return true;
    }
};
