// src/ray.zig

const std = @import("std");

const vec3 = @import("vec3.zig");

const Vec3 = vec3.Vec3;
const Point3 = vec3.Point3;

pub const Ray = struct {
    _orig: Point3 = Point3{},
    _dir: Vec3 = Vec3{},

    pub fn init(orig: Point3, dir: Vec3) Ray {
        return Ray{
            ._orig = orig,
            ._dir = dir,
        };
    }

    pub fn origin(self: Ray) Point3 {
        return self._orig;
    }
    pub fn direction(self: Ray) Vec3 {
        return self._dir;
    }

    pub fn at(self: Ray, t: f64) Point3 {
        return vec3.add(self._orig, vec3.multiplyScalarByVector(t, self._dir));
    }
};
