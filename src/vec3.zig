const std = @import("std");

pub const Vec3 = struct {
    e: [3]f64 = [3]f64{ 0, 0, 0 },

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
        return Vec3{
            .e = [3]f64{
                -self.e[0],
                -self.e[1],
                -self.e[2],
            },
        };
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
    return Vec3{
        .e = [3]f64{
            u.e[0] + v.e[0],
            u.e[1] + v.e[1],
            u.e[2] + v.e[2],
        },
    };
}

pub inline fn subtract(u: Vec3, v: Vec3) Vec3 {
    return Vec3{
        .e = [3]f64{
            u.e[0] - v.e[0],
            u.e[1] - v.e[1],
            u.e[2] - v.e[2],
        },
    };
}

pub inline fn multiplyScalarByVector(t: f64, u: Vec3) Vec3 {
    return Vec3{
        .e = [3]f64{
            t * u.e[0],
            t * u.e[1],
            t * u.e[2],
        },
    };
}
pub inline fn multiplyVectorByScalar(u: Vec3, t: f64) Vec3 {
    return multiplyScalarByVector(t, u);
}

pub inline fn divide(u: Vec3, t: f64) Vec3 {
    return multiplyScalarByVector(1.0 / t, u);
}

// Hadamard product
pub inline fn elementWiseProduct(u: Vec3, v: Vec3) Vec3 {
    return Vec3{
        .e = [3]f64{
            u.e[0] * v.e[0],
            u.e[1] * v.e[1],
            u.e[2] * v.e[2],
        },
    };
}

pub inline fn dotProduct(u: Vec3, v: Vec3) f64 {
    return u.e[0] * v.e[0] + u.e[1] * v.e[1] + u.e[2] * v.e[2];
}

pub inline fn crossProduct(u: Vec3, v: Vec3) Vec3 {
    return Vec3{
        .e = [3]f64{
            u.e[1] * v.e[2] - u.e[2] * v.e[1],
            u.e[2] * v.e[0] - u.e[0] * v.e[2],
            u.e[0] * v.e[1] - u.e[1] * v.e[0],
        },
    };
}

pub inline fn unitVector(v: Vec3) Vec3 {
    return divide(v, v.length());
}
