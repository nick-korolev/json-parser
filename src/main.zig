const std = @import("std");
const tokenizer_pkg = @import("./packages/tokenizer.zig");
const ast = @import("./packages/ast.zig");
const file_reader = @import("./packages/file_reader.zig");

pub fn main() !void {
    const start_time = std.time.milliTimestamp();
    defer {
        const end_time = std.time.milliTimestamp();

        const duration = end_time - start_time;
        std.debug.print("Done: {} ms\n", .{duration});
    }
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leaked = gpa.deinit();
        switch (leaked) {
            .leak => std.debug.print("Leaked\n", .{}),
            .ok => {},
        }
    }
    const allocator = gpa.allocator();

    const file = try file_reader.read_file("./test-data/file.json");

    // const json = "{ \"test\": 1 }";
    var Tokenizer = tokenizer_pkg.Tokenizer.init(file);

    const tokens_list = try Tokenizer.parse(allocator);

    defer {
        tokens_list.deinit();
    }

    for (tokens_list.items) |token| {
        std.debug.print("token: {}\n, token_value: {s}\n", .{ token, token.raw_value });
    }

    // _ = try ast.buildAST(allocator, &tokens_list);
}
