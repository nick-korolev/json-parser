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

pub const Token = struct {
    line: usize,
    column: usize,
    offset: usize,
    token_type: TokenType,
    raw_value: []const u8,
    value: value_parser.ParsedValue,
};

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
        var tokens = try std.ArrayList(Token).initCapacity(allocator, self.source.len / 10);
        errdefer tokens.deinit();

        var token_start = self.index;

        while (self.index < self.source.len) {
            const char = self.source[self.index];

            switch (char) {
                '{', '}', ':' => {
                    if (self.index > token_start) {
                        const raw_value = self.source[token_start..self.index];
                        try tokens.append(Token{
                            .offset = token_start,
                            .column = self.column - (self.index - token_start),
                            .line = self.line,
                            .raw_value = raw_value,
                            .value = value_parser.parse_string(&raw_value),
                            .token_type = .KeyOrValue,
                        });
                    }

                    const raw_value = self.source[token_start..self.index];

                    try tokens.append(Token{
                        .offset = self.index,
                        .column = self.column,
                        .line = self.line,
                        .raw_value = self.source[self.index .. self.index + 1],
                        .token_type = get_token_type(char),
                        .value = value_parser.parse_string(&raw_value),
                    });
                    token_start = self.index + 1;
                },
                ' ', '\t', '\n', '\r' => {
                    if (self.index > token_start) {
                        const raw_value = self.source[token_start..self.index];
                        try tokens.append(Token{
                            .offset = token_start,
                            .column = self.column - (self.index - token_start),
                            .line = self.line,
                            .raw_value = self.source[token_start..self.index],
                            .token_type = .KeyOrValue,
                            .value = value_parser.parse_string(&raw_value),
                        });
                    }
                    if (char == '\n') {
                        self.column = 1;
                        self.line += 1;
                    }
                    token_start = self.index + 1;
                },
                else => {},
            }

            self.index += 1;
            self.column += 1;
        }

        if (self.index > token_start) {
            const raw_value = self.source[token_start..self.index];
            try tokens.append(Token{
                .offset = token_start,
                .column = self.column - (self.index - token_start),
                .line = self.line,
                .raw_value = self.source[token_start..self.index],
                .token_type = .KeyOrValue,
                .value = value_parser.parse_string(&raw_value),
            });
        }

        return tokens;
    }
};
