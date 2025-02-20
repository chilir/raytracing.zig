// src/material.zig

const vec3 = @import("vec3.zig");

const Color = @import("color.zig").Color;
const Ray = @import("ray.zig").Ray;
const HitRecord = @import("hittable.zig").HitRecord;

pub const Material = union(enum) {
    lambertian: Lambertian,
    metal: Metal,

    pub fn scatter(self: Material, r_in: Ray, rec: HitRecord, attenuation: *Color, scattered: *Ray) bool {
        return switch (self) {
            .lambertian => |l| l.scatter(rec, attenuation, scattered),
            .metal => |m| m.scatter(r_in, rec, attenuation, scattered),
        };
    }
};

pub const Lambertian = struct {
    _albedo: Color,

    pub fn init(albedo: Color) Lambertian {
        return Lambertian{
            ._albedo = albedo,
        };
    }

    pub fn scatter(self: Lambertian, rec: HitRecord, attenuation: *Color, scattered: *Ray) bool {
        var scatter_direction = vec3.add(rec.normal, vec3.randomUnitVector());

        if (scatter_direction.nearZero()) {
            scatter_direction = rec.normal;
        }

        scattered.* = Ray.init(rec.p, scatter_direction);
        attenuation.* = self._albedo;
        return true;
    }
};

pub const Metal = struct {
    _albedo: Color,

    pub fn init(albedo: Color) Metal {
        return Metal{
            ._albedo = albedo,
        };
    }

    pub fn scatter(self: Metal, r_in: Ray, rec: HitRecord, attenuation: *Color, scattered: *Ray) bool {
        const reflected = vec3.reflect(r_in.direction(), rec.normal);
        scattered.* = Ray.init(rec.p, reflected);
        attenuation.* = self._albedo;
        return true;
    }
};
