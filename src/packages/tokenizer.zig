const std = @import("std");

pub const Tokenizer = struct {
    source: []const u8,
    index: usize,
    line: usize,
    column: usize,

    pub fn init(source: []const u8) Tokenizer {
        return .{
            .source = source,
            .index = 0,
            .line = 1,
            .column = 1,
        };
    }

    pub fn deinit(_: *Tokenizer) void {
        //
    }

    fn peek(self: Tokenizer) u8 {
        return self.source[self.index];
    }

    pub fn parse(self: *Tokenizer, allocator: std.mem.Allocator) !std.ArrayList([]const u8) {
        var tokens = std.ArrayList([]const u8).init(allocator);
        errdefer {
            for (tokens.items) |token| {
                allocator.free(token);
            }
            tokens.deinit();
        }

        var current_token = std.ArrayList(u8).init(allocator);
        defer current_token.deinit();

        while (self.*.index < self.source.len) {
            const char = self.source[self.*.index];

            switch (char) {
                '{', '}', ':' => {
                    if (current_token.items.len > 0) {
                        try tokens.append(try current_token.toOwnedSlice());
                    }
                    try tokens.append(try allocator.dupe(u8, &[_]u8{char}));
                },
                ' ', '\t', '\n', '\r' => {
                    if (current_token.items.len > 0) {
                        try tokens.append(try current_token.toOwnedSlice());
                        current_token = std.ArrayList(u8).init(allocator);
                    }
                },
                else => {
                    try current_token.append(char);
                },
            }

            self.*.index += 1;
        }

        if (current_token.items.len > 0) {
            try tokens.append(try current_token.toOwnedSlice());
        }

        return tokens;
    }
};
