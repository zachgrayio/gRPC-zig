const std = @import("std");
const GrpcServer = @import("server.zig").GrpcServer;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var server = try GrpcServer.init(allocator, 50051, "secret-key");
    defer server.deinit();

    // Register a simple handler
    try server.handlers.append(.{
        .name = "SayHello",
        .handler_fn = sayHello,
    });

    try server.start();
}

fn sayHello(request: []const u8, allocator: std.mem.Allocator) ![]u8 {
    _ = request;
    return allocator.dupe(u8, "Hello from gRPC!");
}