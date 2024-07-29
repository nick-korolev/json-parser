const std = @import("std");

pub const ParsedValue = union(enum) {
    boolean: bool,
    null_value: void,
    integer: i64,
    float: f64,
    other: []const u8,

    pub fn format(
        self: ParsedValue,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        switch (self) {
            .boolean => |v| try writer.print("boolean: {}", .{v}),
            .null_value => try writer.writeAll("null"),
            .integer => |v| try writer.print("integer: {}", .{v}),
            .float => |v| try writer.print("float: {}", .{v}),
            .other => |v| try writer.print("other: {s}", .{v}),
        }
    }
};

pub fn parse_string(str: *const []const u8) ParsedValue {
    const str_val = str.*;
    if (std.mem.eql(u8, str_val, "true")) return ParsedValue{ .boolean = true };
    if (std.mem.eql(u8, str_val, "false")) return ParsedValue{ .boolean = false };
    if (std.mem.eql(u8, str_val, "null")) return ParsedValue{ .null_value = {} };

    if (std.fmt.parseInt(i64, str_val, 10)) |int_value| {
        return ParsedValue{ .integer = int_value };
    } else |_| {
        if (std.fmt.parseFloat(f64, str_val)) |float_value| {
            return ParsedValue{ .float = float_value };
        } else |_| {
            return ParsedValue{ .other = str_val };
        }
    }
}
