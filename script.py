#!/usr/bin/python3

import socket

HOST = '127.0.0.1'
PORT = 9000

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect((HOST, PORT))

bytes = bytearray()
bytes.append(3)
bytes.append(0)
bytes.append(1)

sock.sendall(bytes)

exit(0)
