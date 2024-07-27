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

    pub fn parse(self: *Tokenizer) *Tokenizer {
        // skipping initial {
        self.*.index += 1;
        // var token = Token{
        //     .column = 1,
        //     .line = 1,
        //     .offset = 0,
        //     .key = "",
        //     .value = "",
        // };

        while (self.peek() != '}') {
            const char = self.peek();
            if (char == '"') {
                self.*.index += 1;
                var index: usize = 0;
                while (self.peek() != '"') {
                    std.debug.print("subsymbol: {c}\n", .{self.peek()});
                    index += 1;
                    self.*.index += 1;
                    std.debug.print("index {}\n", .{index});
                }
            }
            std.debug.print("symbol: {c}\n", .{char});
            self.*.index += 1;
        }

        return self;
    }
};
