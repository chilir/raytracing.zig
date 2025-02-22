// src/vec3.zig

const std = @import("std");

const utils = @import("utils.zig");

pub const Vec3 = struct {
    e: [3]f64 = [3]f64{ 0, 0, 0 },

    pub fn init(e0: f64, e1: f64, e2: f64) Vec3 {
        return Vec3{ .e = [3]f64{ e0, e1, e2 } };
    }

    pub fn x(self: Vec3) f64 {
        return self.e[0];
    }
    pub fn y(self: Vec3) f64 {
        return self.e[1];
    }
    pub fn z(self: Vec3) f64 {
        return self.e[2];
    }

    pub fn negate(self: Vec3) Vec3 {
        return init(
            -self.e[0],
            -self.e[1],
            -self.e[2],
        );
    }

    pub fn addInPlace(self: *Vec3, v: Vec3) void {
        self.e[0] += v.e[0];
        self.e[1] += v.e[1];
        self.e[2] += v.e[2];
    }

    pub fn multiplyInPlace(self: *Vec3, t: f64) void {
        self.e[0] *= t;
        self.e[1] *= t;
        self.e[2] *= t;
    }

    pub fn divideInPlace(self: *Vec3, t: f64) void {
        self.multiplyInPlace(1 / t);
    }

    pub fn length(self: Vec3) f64 {
        return std.math.sqrt(self.lengthSquared());
    }

    pub fn lengthSquared(self: Vec3) f64 {
        return self.e[0] * self.e[0] + self.e[1] * self.e[1] + self.e[2] * self.e[2];
    }

    pub fn nearZero(self: Vec3) bool {
        const s = 1e-8;
        return (@abs(self.e[0]) < s) and
            (@abs(self.e[1]) < s) and
            (@abs(self.e[2]) < s);
    }

    pub fn random() Vec3 {
        return Vec3.init(
            utils.randomFloat(),
            utils.randomFloat(),
            utils.randomFloat(),
        );
    }

    pub fn randomFromRange(min: f64, max: f64) Vec3 {
        return Vec3.init(
            utils.randomFloatFromRange(min, max),
            utils.randomFloatFromRange(min, max),
            utils.randomFloatFromRange(min, max),
        );
    }

    pub fn format(
        self: Vec3,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        try writer.print("{d} {d} {d}", .{ self.e[0], self.e[1], self.e[2] });
    }
};

pub const Point3 = Vec3;

pub inline fn add(u: Vec3, v: Vec3) Vec3 {
    return Vec3.init(
        u.e[0] + v.e[0],
        u.e[1] + v.e[1],
        u.e[2] + v.e[2],
    );
}

pub inline fn subtract(u: Vec3, v: Vec3) Vec3 {
    return Vec3.init(
        u.e[0] - v.e[0],
        u.e[1] - v.e[1],
        u.e[2] - v.e[2],
    );
}

pub inline fn multiplyScalarByVector(t: f64, u: Vec3) Vec3 {
    return Vec3.init(
        t * u.e[0],
        t * u.e[1],
        t * u.e[2],
    );
}
pub inline fn multiplyVectorByScalar(u: Vec3, t: f64) Vec3 {
    return multiplyScalarByVector(t, u);
}

pub inline fn divide(u: Vec3, t: f64) Vec3 {
    return multiplyScalarByVector(1.0 / t, u);
}

// Hadamard product
pub inline fn elementWiseProduct(u: Vec3, v: Vec3) Vec3 {
    return Vec3.init(
        u.e[0] * v.e[0],
        u.e[1] * v.e[1],
        u.e[2] * v.e[2],
    );
}

pub inline fn dotProduct(u: Vec3, v: Vec3) f64 {
    return u.e[0] * v.e[0] + u.e[1] * v.e[1] + u.e[2] * v.e[2];
}

pub inline fn crossProduct(u: Vec3, v: Vec3) Vec3 {
    return Vec3.init(
        u.e[1] * v.e[2] - u.e[2] * v.e[1],
        u.e[2] * v.e[0] - u.e[0] * v.e[2],
        u.e[0] * v.e[1] - u.e[1] * v.e[0],
    );
}

pub inline fn unitVector(v: Vec3) Vec3 {
    return divide(v, v.length());
}

pub inline fn randomUnitVector() Vec3 {
    while (true) {
        const p = Vec3.randomFromRange(-1, 1);
        const lensq = p.lengthSquared();
        if (1e-160 < lensq and lensq <= 1) {
            return divide(p, std.math.sqrt(lensq));
        }
    }
}

pub inline fn randomOnHemisphere(normal: Vec3) Vec3 {
    const on_unit_sphere = randomUnitVector();
    if (dotProduct(on_unit_sphere, normal) > 0.0) {
        return on_unit_sphere;
    }
    return on_unit_sphere.negate();
}

pub inline fn reflect(v: Vec3, n: Vec3) Vec3 {
    return subtract(v, multiplyScalarByVector(2 * dotProduct(v, n), n));
}

pub inline fn refract(uv: Vec3, n: Vec3, etai_over_etat: f64) Vec3 {
    const cos_theta = @min(dotProduct(uv.negate(), n), 1.0);
    const r_out_perp = multiplyScalarByVector(
        etai_over_etat,
        add(uv, multiplyScalarByVector(cos_theta, n)),
    );
    const r_out_parallel = multiplyScalarByVector(
        -std.math.sqrt(@abs(1.0 - r_out_perp.lengthSquared())),
        n,
    );
    return add(r_out_perp, r_out_parallel);
}

pub inline fn randomInUnitDisk() Vec3 {
    while (true) {
        const p = Vec3.init(
            utils.randomFloatFromRange(-1, 1),
            utils.randomFloatFromRange(-1, 1),
            0,
        );
        if (p.lengthSquared() < 1) {
            return p;
        }
    }
}
