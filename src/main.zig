const std = @import("std");
const tokenizer_pkg = @import("./packages/tokenizer.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leaked = gpa.deinit();
        switch (leaked) {
            .leak => std.debug.print("Leaked", .{}),
            .ok => {},
        }
    }
    _ = gpa.allocator();

    const json = "{ \"test\": 1 }";
    var Tokenizer = tokenizer_pkg.Tokenizer.init(json);

    _ = Tokenizer.parse();
}
