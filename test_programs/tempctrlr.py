import serial
import time

ser = serial.Serial(
    port='COM1',
    baudrate=4800,
    bytesize=serial.SEVENBITS,
    parity=serial.PARITY_ODD,
    stopbits=serial.STOPBITS_ONE,
    timeout=1
)

def send_and_receive(command_bytes):
    ser.write(command_bytes)
    time.sleep(0.1)
    response = ser.read(64)
    return response


enq = bytes([0x05])
enqout = send_and_receive(enq)
if enqout:
    print("Enquiry: Acknowledged")


setnum = bytes([0x02]) + b'P01' + bytes([0x0D])
setnumout = send_and_receive(setnum)
if setnumout == b'':
    print("Numbering Response: None")
else:
    print("Pump numbered successfully.")        


speed = bytes([0x02]) + b'P01S+0100.0V300.0G' + bytes([0x0D])
speedout = send_and_receive(speed)

if speedout == b'\x06':
    print("Pump Set Speed Response: Acknowledged")


status = bytes([0x02]) + b'P01I' + bytes([0x0D])
statusout = send_and_receive(status)

statstr = statusout.decode("utf-8")

print("Pump Number:", statstr[2:4]) # Pump Number Response
print(statstr)
# Operating Status
if statstr[5] == "1":
    print("Operating Status: Remote")
else:
    print("Operating Status: Local")
    
# Aux Out
if statstr[6] == "1":
    print("Aux Output: On")
else:
    print("Aux Output: Off")

# Aux In    
if statstr[7] == "1":
    print("Aux input: Closed")
else:
    print("Aux Input: Open")

# Status

if statstr[8] == "1":
    print("Status: Numbered")
elif statstr[8] == "2":
    print("Status: Instructed")
elif statstr[8] == "3":
    print("Status: Running")
elif statstr[8] == "4":
    print("Status: Pump Manually Stopped")
elif statstr[8] == "5":
    print("Status: No Motor Feedback")
elif statstr[8] == "6":
    print("Status: OVERLOAD")
elif statstr[8] == "7":
    print("Status: Excessive Motor Feedback")

if statstr[9] == "0":
    print("COM: No Error")
elif statstr[9] == "1":
    print("COM: Parity Error")
elif statstr[9] == "2":
    print("COM: Framing Error")
elif statstr[9] == "3":
    print("COM: Overrun Error")
elif statstr[9] == "4":
    print("COM: Invalid Command")
elif statstr[9] == "5":
    print("COM: Invalid Data")



time.sleep(5)

check =  send_and_receive(bytes([0x02]) + b'P01H' + bytes([0x0D]))

if check == b'\x06':
    print("PUMP SUCESSFULLY CLOSED\n")

ser.close()

