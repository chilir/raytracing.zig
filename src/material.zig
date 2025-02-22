// src/material.zig

const std = @import("std");
const vec3 = @import("vec3.zig");
const utils = @import("utils.zig");

const Color = @import("color.zig").Color;
const Ray = @import("ray.zig").Ray;
const HitRecord = @import("hittable.zig").HitRecord;

pub const Material = union(enum) {
    lambertian: Lambertian,
    metal: Metal,
    dielectric: Dielectric,

    pub fn scatter(
        self: Material,
        r_in: Ray,
        rec: HitRecord,
        attenuation: *Color,
        scattered: *Ray,
    ) bool {
        return switch (self) {
            .lambertian => |l| l.scatter(rec, attenuation, scattered),
            .metal => |m| m.scatter(r_in, rec, attenuation, scattered),
            .dielectric => |d| d.scatter(r_in, rec, attenuation, scattered),
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
    _fuzz: f64,

    pub fn init(albedo: Color, fuzz: f64) Metal {
        return Metal{
            ._albedo = albedo,
            ._fuzz = if (fuzz < 1) fuzz else 1,
        };
    }

    pub fn scatter(
        self: Metal,
        r_in: Ray,
        rec: HitRecord,
        attenuation: *Color,
        scattered: *Ray,
    ) bool {
        var reflected = vec3.reflect(r_in.direction(), rec.normal);
        reflected = vec3.add(
            vec3.unitVector(reflected),
            vec3.multiplyScalarByVector(self._fuzz, vec3.randomUnitVector()),
        );
        scattered.* = Ray.init(rec.p, reflected);
        attenuation.* = self._albedo;
        return vec3.dotProduct(scattered.direction(), rec.normal) > 0;
    }
};

pub const Dielectric = struct {
    _refraction_index: f64,

    pub fn init(refraction_index: f64) Dielectric {
        return Dielectric{
            ._refraction_index = refraction_index,
        };
    }

    pub fn scatter(
        self: Dielectric,
        r_in: Ray,
        rec: HitRecord,
        attenuation: *Color,
        scattered: *Ray,
    ) bool {
        attenuation.* = Color.init(1.0, 1.0, 1.0);
        const ri = if (rec.front_face) 1.0 / self._refraction_index else self._refraction_index;

        const unit_direction = vec3.unitVector(r_in.direction());
        const cos_theta = @min(vec3.dotProduct(unit_direction.negate(), rec.normal), 1.0);
        const sin_theta = std.math.sqrt(1.0 - cos_theta * cos_theta);

        const cannot_refract = ri * sin_theta > 1.0;
        var direction = vec3.Vec3{};
        if (cannot_refract or reflectance(cos_theta, ri) > utils.randomFloat()) {
            direction = vec3.reflect(unit_direction, rec.normal);
        } else {
            direction = vec3.refract(unit_direction, rec.normal, ri);
        }

        scattered.* = Ray.init(rec.p, direction);
        return true;
    }

    fn reflectance(cosine: f64, refraction_index: f64) f64 {
        var r0 = (1 - refraction_index) / (1 + refraction_index);
        r0 = r0 * r0;
        return r0 + (1 - r0) * std.math.pow(f64, 1 - cosine, 5);
    }
};
