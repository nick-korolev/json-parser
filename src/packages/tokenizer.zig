const std = @import("std");
const value_parser = @import("./value_parser.zig");

pub const TokenType = enum {
    KeyOrValue,
    Comma,
    Assignment,
    ObjectOpen,
    ObjectClose,
    ArrayOpen,
    ArrayClose,
};

pub const Token = struct { line: usize, column: usize, offset: usize, token_type: TokenType, raw_value: []const u8 };

fn get_token_type(char: u8) TokenType {
    return switch (char) {
        ',' => .Comma,
        ':' => .Assignment,
        '{' => .ObjectOpen,
        '}' => .ObjectClose,
        '[' => .ArrayOpen,
        ']' => .ArrayClose,
        else => .KeyOrValue,
    };
}

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

    pub fn deinit(_: *Tokenizer) void {}

    pub fn parse(self: *Tokenizer, allocator: std.mem.Allocator) !std.ArrayList(Token) {
        var tokens = std.ArrayList(Token).init(allocator);
        errdefer {
            for (tokens.items) |token| {
                allocator.free(token.raw_value);
            }
            tokens.deinit();
        }

        var current_token_raw_value = std.ArrayList(u8).init(allocator);
        defer current_token_raw_value.deinit();

        while (self.index < self.source.len) {
            const char = self.source[self.index];

            switch (char) {
                '{', '}', ':' => {
                    if (current_token_raw_value.items.len > 0) {
                        try self.appendCurrentToken(&tokens, &current_token_raw_value, allocator);
                    }

                    try self.appendSingleCharToken(&tokens, char, allocator);
                },
                ' ', '\t', '\n', '\r' => {
                    if (current_token_raw_value.items.len > 0) {
                        try self.appendCurrentToken(&tokens, &current_token_raw_value, allocator);
                    }
                    if (char == '\n') {
                        self.column = 1;
                        self.line += 1;
                    }
                },
                else => {
                    try current_token_raw_value.append(char);
                },
            }

            self.index += 1;
            self.column += 1;
        }

        if (current_token_raw_value.items.len > 0) {
            try self.appendCurrentToken(&tokens, &current_token_raw_value, allocator);
        }

        return tokens;
    }

    fn appendCurrentToken(self: *Tokenizer, tokens: *std.ArrayList(Token), current_token_raw_value: *std.ArrayList(u8), allocator: std.mem.Allocator) !void {
        const curr_token_val = try allocator.dupe(u8, current_token_raw_value.items);
        const token = Token{
            .offset = self.index - curr_token_val.len,
            .column = self.column - curr_token_val.len,
            .line = self.line,
            .raw_value = curr_token_val,
            .token_type = .KeyOrValue,
        };
        try tokens.append(token);

        current_token_raw_value.clearRetainingCapacity();
    }

    fn appendSingleCharToken(self: *Tokenizer, tokens: *std.ArrayList(Token), char: u8, allocator: std.mem.Allocator) !void {
        const curr_token_val = try allocator.dupe(u8, &[_]u8{char});
        const token = Token{
            .offset = self.index,
            .column = self.column,
            .line = self.line,
            .raw_value = curr_token_val,
            .token_type = get_token_type(char),
        };
        try tokens.append(token);
    }
};
