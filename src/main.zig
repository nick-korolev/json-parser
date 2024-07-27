const std = @import("std");
const tokenizer_pkg = @import("./packages/tokenizer.zig");
const ast = @import("./packages/ast.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leaked = gpa.deinit();
        switch (leaked) {
            .leak => std.debug.print("Leaked", .{}),
            .ok => {},
        }
    }
    const allocator = gpa.allocator();

    const json = "{ \"test\": 1 }";
    var Tokenizer = tokenizer_pkg.Tokenizer.init(json);

    const tokens_list = try Tokenizer.parse(allocator);
    defer {
        for (tokens_list.items) |token| {
            allocator.free(token.raw_value);
        }
        tokens_list.deinit();
    }

    for (tokens_list.items) |token| {
        std.debug.print("token: {}\n, token_value: {s}\n", .{ token, token.raw_value });
    }

    // _ = try ast.buildAST(allocator, &tokens_list);
}
