const std = @import("std");
const net = std.net;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};

const packet = struct {
    tag: u8,
    length: u16,
    data: []u8,

    const Self = @This();

    fn new(tag: u8, length: u16, data: []u8) Self {
        return packet{ .tag = tag, .length = length, .data = data };
    }

    fn destroy(self: *Self) void {
        gpa.allocator().free(self.data);
    }

    fn print_data(self: *Self) void {
        std.debug.print("{s}\n", .{self.data});
    }
};

pub fn read_packet(stream: net.Stream) net.Stream.ReadError!packet {
    var header_buf: [3]u8 = undefined;
    const header_len = try stream.readAtLeast(&header_buf, 3);

    if (header_len < 3) return net.Stream.ReadError.Unexpected;
    const length = @as(u16, header_buf[1]) << @as(u16, 8) | @as(u16, header_buf[2]);

    const buf_data = gpa.allocator().alloc(u8, length) catch {
        return net.Stream.ReadError.SystemResources;
    };
    const data = try stream.readAtLeast(buf_data, length);

    if (data < length) return net.Stream.ReadError.Unexpected;

    return packet.new(header_buf[0], length, buf_data);
}

const addr = net.Address.initIp4(.{ 127, 0, 0, 1 }, 3000);

pub fn main() !void {
    var server = try net.Address.listen(addr, .{ .reuse_address = true });
    defer server.deinit();

    std.log.info("Listening at: {}\n", .{server.listen_address});

    while (true) {
        const conn = try server.accept();
        handle_conn(conn) catch |e| {
            std.log.err("{}", .{e});
        };
    }
}

fn handle_conn(conn: std.net.Server.Connection) net.Stream.ReadError!void {
    defer conn.stream.close();

    var pkt = try read_packet(conn.stream);
    defer pkt.destroy();
    std.log.info("pkt = {}", .{pkt});
    pkt.print_data();
}
