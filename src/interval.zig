// src/interval.zig

const utils = @import("utils.zig");

pub const Interval = struct {
    // default is empty interval
    min: f64 = utils.INFINITY,
    max: f64 = -utils.INFINITY,

    pub fn init(min: f64, max: f64) Interval {
        return .{
            .min = min,
            .max = max,
        };
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

    pub fn clamp(self: Interval, x: f64) f64 {
        if (x < self.min) return self.min;
        if (x > self.max) return self.max;
        return x;
    }

    pub const empty = Interval{};
    pub const universe = Interval.init(-utils.INFINITY, utils.INFINITY);
};
