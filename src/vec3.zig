const std = @import("std");

pub const Vec3 = struct {
    x: f64 = 0,
    y: f64 = 0,
    z: f64 = 0,

    pub fn negate(self: Vec3) Vec3 {
        return Vec3{
            .x = -self.x,
            .y = -self.y,
            .z = -self.z,
        };
    }

    pub fn addInPlace(self: *Vec3, v: Vec3) void {
        self.x += v.x;
        self.y += v.y;
        self.z += v.z;
    }

    pub fn multiplyInPlace(self: *Vec3, t: f64) void {
        self.x *= t;
        self.y *= t;
        self.z *= t;
    }

    pub fn divideInPlace(self: *Vec3, t: f64) void {
        self.x /= t;
        self.y /= t;
        self.z /= t;
    }

    pub fn length(self: Vec3) f64 {
        return std.math.sqrt(self.lengthSquared());
    }

    pub fn lengthSquared(self: Vec3) f64 {
        return self.x * self.x + self.y * self.y + self.z * self.z;
    }

    pub fn format(self: Vec3, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        try writer.print("{d} {d} {d}", .{ self.x, self.y, self.z });
    }
};

pub const Point3 = Vec3;

inline fn add(u: Vec3, v: Vec3) Vec3 {
    return Vec3{
        .x = u.x + v.x,
        .y = u.y + v.y,
        .z = u.z + v.z,
    };
}

inline fn subtract(u: Vec3, v: Vec3) Vec3 {
    return Vec3{
        .x = u.x - v.x,
        .y = u.y - v.y,
        .z = u.z - v.z,
    };
}

inline fn multiply(u: Vec3, t: f64) Vec3 {
    return Vec3{
        .x = u.x * t,
        .y = u.y * t,
        .z = u.z * t,
    };
}

inline fn divide(u: Vec3, t: f64) Vec3 {
    const inverse_t = 1.0 / t;
    return Vec3{
        .x = u.x * inverse_t,
        .y = u.y * t,
        .z = u.z * t,
    };
}

// Hadamard product
inline fn elementWiseProduct(u: Vec3, v: Vec3) Vec3 {
    return Vec3{
        .x = u.x * v.x,
        .y = u.y * v.y,
        .z = u.z * v.z,
    };
}

inline fn dotProduct(u: Vec3, v: Vec3) f64 {
    return u.x * v.x + u.y * v.y + u.z * v.z;
}

inline fn crossProduct(u: Vec3, v: Vec3) Vec3 {
    return Vec3{
        .x = u.y * v.z - u.z * v.y,
        .y = u.z * v.x - u.x * v.z,
        .z = u.x * v.y - u.y * v.x,
    };
}

inline fn unitVector(v: Vec3) Vec3 {
    return divide(v / v.length());
}
