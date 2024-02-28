const std = @import("std");
const net = std.net;

const packet = packed struct {
    tag: u8,
    length: u16,
};

pub fn read_packet(stream: net.Stream) !packet {
    var buf: [3]u8 = undefined;
    std.debug.assert(try stream.read(&buf) == 3);

    return packet{
        .tag = buf[0],
        .length = @as(u16, buf[1]) << @as(u16, 8) | @as(u16, buf[2]),
    };
}

pub fn main() !void {
    var running = true;
    var server = net.StreamServer.init(.{});
    defer {
        server.deinit();
        server.close();
    }

    try server.listen(try net.Address.parseIp("127.0.0.1", 9000));
    std.log.info("Listening at: {}\n", .{server.listen_address});

    while (running) {
        var conn = try server.accept();
        defer conn.stream.close();

        var pkt = try read_packet(conn.stream);
        std.log.info("Packet = {}", .{pkt});
    }
}
