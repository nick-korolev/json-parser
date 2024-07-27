const std = @import("std");

pub const NodeType = enum {
    Object,
    Array,
    String,
    Number,
    Boolean,
    Null,
};

pub const Node = struct {
    type: NodeType,
    rawValue: *const []const u8,
    children: ?std.ArrayList(*Node),

    pub fn init(allocator: std.mem.Allocator, node_type: NodeType, node_value: *const []const u8) !*Node {
        const node = try allocator.create(Node);
        node.* = .{
            .type = node_type,
            .rawValue = node_value,
            .children = if (node_type == .Object or node_type == .Array)
                std.ArrayList(*Node).init(allocator)
            else
                null,
        };
        return node;
    }

    pub fn deinit(self: *Node, allocator: std.mem.Allocator) void {
        if (self.children) |*children| {
            for (children.items) |child| {
                child.deinit(allocator);
            }
            children.deinit();
        }
        allocator.destroy(self);
    }

    pub fn format(
        self: *Node,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;

        try writer.print("Node{{ type: {}, rawValue: \"{s}\"", .{ self.type, self.rawValue.* });

        if (self.children) |children| {
            try writer.writeAll(", children: [");
            for (children.items, 0..) |child, i| {
                if (i > 0) try writer.writeAll(", ");
                try writer.print("{*}", .{child});
            }
            try writer.writeAll("]");
        }

        try writer.writeAll(" }");
    }
};

pub fn buildAST(allocator: std.mem.Allocator, tokensList: *const std.ArrayListAligned([]const u8, null)) !void {
    const parent_object = try Node.init(allocator, NodeType.Object, &"ParentObject");
    defer {
        parent_object.deinit(allocator);
    }
    for (tokensList.*.items) |token| {
        const child_node = try Node.init(allocator, NodeType.Array, &token);
        std.debug.print("Child Node {}\n", .{child_node});
        try parent_object.children.?.append(child_node);
    }
    std.debug.print("Parent node: {}\n", .{parent_object});
}
