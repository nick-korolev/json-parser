const std = @import("std");

const ReadFileError = error{ Error1, Error2 };

pub fn read_file(path: []const u8) ![]u8 {
    const cwd = std.fs.cwd();
    const file = cwd.readFileAlloc(std.heap.page_allocator, path, std.math.maxInt(usize));
    return file;
}
