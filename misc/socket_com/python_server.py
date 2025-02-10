import socket
import time
import numpy as np
import json
import struct

t = time.time()

# SOCKET PARAMETERS
host='localhost'
port=8802

# CREATE SOCKET
s=socket.socket()
s.bind((host,port)) #Bind Port And Host
s.listen(2)  # Socket is Listening to 2 streams max.
print("Socket Is Listening....")
connection, address = s.accept()
print("Connected To ", address)

# We need to read by chunks because our complete array is over 700kb and thats too much to send in one packet
def readByChunk():
    chunks = []
    bytes_recd = 0
    data = b''
    length_bytes = connection.recv(4)
    #print(length_bytes)
    # if there is only byte delimiter it means no message is actually sent
    if length_bytes <= data:
        msg = False
        return

    # On Java side, we write the length of message. Its necessary so we know when to stop reading chunks
    # and return the current frame
    #TO DO: to have a more robust implementation, we should also return whenever we find a "stop byte"
    MSGLEN = struct.unpack('>I', length_bytes)[0]
    print(f"Message length received: {MSGLEN} bytes")

    while bytes_recd < MSGLEN:
        # I am not sure this is necessary ?
        chunk = connection.recv(min(MSGLEN - bytes_recd, 2048))
        chunks.append(chunk)
        bytes_recd = bytes_recd + len(chunk)

    msg = b''.join(chunks)
    return msg

# Opening only for 10 minutes , for testing it should be enough
while(t + 600 > time.time() ):

    msg = readByChunk()
    # only convert to array when there is some message
    if msg:
        print(msg)
        msg = msg.decode("utf-8")
        #print(msg)
        #print(len(msg))

        arr = np.array(json.loads(msg))
        print(type(arr))
        print(arr.shape)

s.close() #Close connection
print("Connection Closed.")
