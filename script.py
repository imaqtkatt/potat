#!/usr/bin/python3

import socket

HOST = '127.0.0.1'
PORT = 3000

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect((HOST, PORT))

b = bytearray()
b.append(0)
b.append(0xFF)
b.append(0xFF)
for i in range(0xFFFF):
  b.append(42)

sock.sendall(b)

exit(0)
