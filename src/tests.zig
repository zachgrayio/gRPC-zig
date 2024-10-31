const std = @import("std");
const testing = std.testing;
const proto = @import("proto/service.zig");
const spice = @import("spice");

test "HelloRequest encode/decode" {
    const request = proto.HelloRequest{ .name = "test" };
    var buf: [1024]u8 = undefined;
    var writer = spice.ProtoWriter.init(&buf);
    try request.encode(&writer);

    var reader = spice.ProtoReader.init(buf[0..writer.pos]);
    const decoded = try proto.HelloRequest.decode(&reader);
    try testing.expectEqualStrings("test", decoded.name);
}

test "HelloResponse encode/decode" {
    const response = proto.HelloResponse{ .message = "Hello, test!" };
    var buf: [1024]u8 = undefined;
    var writer = spice.ProtoWriter.init(&buf);
    try response.encode(&writer);

    var reader = spice.ProtoReader.init(buf[0..writer.pos]);
    const decoded = try proto.HelloResponse.decode(&reader);
    try testing.expectEqualStrings("Hello, test!", decoded.message);
}