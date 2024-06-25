const std = @import("std");
const net = std.net;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};

const Packet = struct {
    tag: u8,
    length: u16,
    data: []u8,

    const Self = @This();

    fn destroy(self: *Self) void {
        gpa.allocator().free(self.data);
    }

    fn print_data(self: *Self) void {
        std.debug.print("{s}\n", .{self.data});
    }
};

pub fn read_packet(stream: net.Stream) net.Stream.ReadError!Packet {
    var buf: [3]u8 = undefined;
    const len = try stream.readAtLeast(&buf, 3);

    if (len < 3) return net.Stream.ReadError.Unexpected;

    const buf_data = gpa.allocator().alloc(u8, len) catch {
        return net.Stream.ReadError.SystemResources;
    };
    const data = try stream.readAtLeast(buf_data, len);

    if (data < len) return net.Stream.ReadError.Unexpected;

    return Packet{
        .tag = buf[0],
        .length = @as(u16, buf[1]) << @as(u16, 8) | @as(u16, buf[2]),
        .data = buf_data,
    };
}

const addr = net.Address.initIp4(.{ 127, 0, 0, 1 }, 3000);

pub fn main() !void {
    const opts = net.Address.ListenOptions{ .reuse_address = true, .force_nonblocking = false, .kernel_backlog = 128, .reuse_port = true };
    var server = try net.Address.listen(addr, opts);
    defer server.deinit();

    std.log.info("Listening at: {}\n", .{server.listen_address});

    while (true) {
        var conn = try server.accept();
        defer conn.stream.close();

        var pkt = read_packet(conn.stream) catch |e| {
            std.log.err("{}", .{e});
            continue;
        };
        defer pkt.destroy();
        std.log.info("pkt = {}", .{pkt});
        pkt.print_data();
    }
}
