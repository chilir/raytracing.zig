// src/utils.zig

const std = @import("std");
const rand = std.crypto.random;

// some math utils
pub const infinity = std.math.inf(f64);
pub const pi = std.math.pi;

pub inline fn degreesToRadians(degrees: f64) f64 {
    return degrees * (pi / 180.0);
}

pub inline fn randomFloat() f64 {
    return rand.float(f64);
}
pub inline fn randomFloatFromRange(min: f64, max: f64) f64 {
    return min + (max - min) * rand.float(f64);
}
