const std = @import("std");
const zlib = std.compress.zlib;

pub const Compression = struct {
    pub const Algorithm = enum {
        none,
        gzip,
        deflate,
    };

    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Compression {
        return .{ .allocator = allocator };
    }

    pub fn compress(self: *Compression, data: []const u8, algorithm: Algorithm) ![]u8 {
        switch (algorithm) {
            .none => return self.allocator.dupe(u8, data),
            .gzip => {
                var compressed = std.ArrayList(u8).init(self.allocator);
                var compressor = try zlib.compressStream(self.allocator, compressed.writer(), .{});
                try compressor.writer().writeAll(data);
                try compressor.finish();
                return compressed.toOwnedSlice();
            },
            .deflate => {
                // Similar to gzip but with different zlib parameters
                var compressed = std.ArrayList(u8).init(self.allocator);
                var compressor = try zlib.compressStream(self.allocator, compressed.writer(), .{ .header_type = .deflate });
                try compressor.writer().writeAll(data);
                try compressor.finish();
                return compressed.toOwnedSlice();
            },
        }
    }

    pub fn decompress(self: *Compression, data: []const u8, algorithm: Algorithm) ![]u8 {
        switch (algorithm) {
            .none => return self.allocator.dupe(u8, data),
            .gzip, .deflate => {
                var decompressed = std.ArrayList(u8).init(self.allocator);
                var decompressor = try zlib.decompressStream(self.allocator, decompressed.writer());
                try decompressor.writer().writeAll(data);
                try decompressor.finish();
                return decompressed.toOwnedSlice();
            },
        }
    }
};