// src/hittable.zig

const std = @import("std");

const vec3 = @import("vec3.zig");
const ray = @import("ray.zig");

const Vec3 = vec3.Vec3;
const Point3 = vec3.Point3;
const Ray = ray.Ray;

pub const HitRecord = struct {
    p: Point3,
    normal: Vec3,
    t: f64,
    front_face: bool,

    fn set_face_normal(self: *HitRecord, r: Ray, outward_normal: Vec3) void {
        self.front_face = vec3.dotProduct(r.direction(), outward_normal) < 0;
        self.normal = if (self.front_face) outward_normal else -outward_normal;
    }
};

pub const Hittable = union(enum) {
    sphere: Sphere,

    pub fn hit(self: Hittable, r: Ray) bool {
        return switch (self) {
            .sphere => |s| s.hit(r),
        };
    }
};

const Sphere = struct {
    _center: Point3,
    _radius: f64,

    pub fn init(center: Point3, radius: f64) Sphere {
        return Sphere{
            ._center = center,
            ._radius = std.math.max(0, radius),
        };
    }

    fn hit(self: Sphere, r: Ray, ray_tmin: f64, ray_tmax: f64, rec: *HitRecord) bool {
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
        if (root <= ray_tmin or ray_tmax <= root) {
            root = (h + sqrtd) / a;
            if (root <= ray_tmin or ray_tmax <= root) {
                return false;
            }
        }

        rec.t = root;
        rec.p = r.at(rec.t);
        const outward_normal = vec3.divide(vec3.subtract(rec.p, self._center), self._radius);
        rec.set_face_normal(r, outward_normal);

        return true;
    }
};
