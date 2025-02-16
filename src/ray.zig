const vec3 = @import("vec3.zig");
const std = @import("std");

pub const Ray = struct {
    _orig: vec3.Point3,
    _dir: vec3.Vec3,

    pub fn origin(self: Ray) vec3.Point3 {
        return self._orig;
    }
    pub fn direction(self: Ray) vec3.Vec3 {
        return self._dir;
    }

    pub fn at(self: Ray, t: f64) vec3.Point3 {
        return vec3.add(self._orig, vec3.multiplyScalarByVector(t, self._dir));
    }
};
