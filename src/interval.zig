// src/interval.zig

const std = @import("std");

pub const Interval = struct {
    // default is empty interval
    min: f64 = std.math.inf(f64),
    max: f64 = -std.math.inf(f64),

    pub fn init(min: f64, max: f64) Interval {
        return Interval{ .min = min, .max = max };
    }

    pub fn size(self: Interval) f64 {
        return self.max - self.min;
    }

    pub fn contains(self: Interval, x: f64) bool {
        return x >= self.min and x <= self.max;
    }

    pub fn surrounds(self: Interval, x: f64) bool {
        return x > self.min and x < self.max;
    }

    pub const empty = Interval{};
    pub const universe = Interval.init(-std.math.inf(f64), std.math.inf(f64));
};
