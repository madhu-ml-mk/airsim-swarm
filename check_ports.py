import socket

ports = [14540, 14541, 14542]

for port in ports:
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    result = sock.connect_ex(('127.0.0.1', port))
    if result == 0:
        print(f"Port {port} is open")
    else:
        print(f"Port {port} is closed")
    sock.close()
