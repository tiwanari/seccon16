from socket import *

IP = "vermatrix.pwn.democrat"
PORT = 4201

sock = socket(AF_INET, SOCK_STREAM)

sock.connect((IP, PORT))

# READ
s = sock.recv(1024)
print s

# WRITE
s = "foo"
sock.send(str(len(s)) + '\n')
s = sock.recv(1024)
print s
