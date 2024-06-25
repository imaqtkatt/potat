#!/usr/bin/python3

import socket

HOST = '127.0.0.1'
PORT = 3000

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect((HOST, PORT))

b = bytearray()
b.append(0)
b.append(0)
b.append(3)
b.append(42)
b.append(42)
b.append(42)

sock.sendall(b)

exit(0)
