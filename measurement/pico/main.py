import sys
import select
import time
from machine import UART, Pin

uart = UART(0, baudrate=115200, tx=Pin(16), rx=Pin(17))
poll = select.poll()
poll.register(sys.stdin, select.POLLIN)

power_pin = Pin(18, Pin.IN, Pin.PULL_DOWN)

power_on_time = None
first_char_time = None
power_flag = False
char_flag = False
result_printed = False

def power_isr(pin):
    global power_on_time, power_flag, char_flag, result_printed
    if pin.value():  # rising edge: board just powered on
        if not power_flag:
            power_on_time = time.ticks_us()
            power_flag = True
    else:  # falling edge: board just powered off/unplugged
        power_flag = False
        char_flag = False
        result_printed = False

power_pin.irq(trigger=Pin.IRQ_RISING | Pin.IRQ_FALLING, handler=power_isr)

while True:

    if power_flag and char_flag and not result_printed:
        elapsed_us = time.ticks_diff(first_char_time, power_on_time)
        sys.stdout.buffer.write(
            "\r\n[ROM phase] {} us ({:.3f} ms)\r\n".format(
                elapsed_us, elapsed_us / 1000
            ).encode()
        )
        result_printed = True

    if uart.any():
        if power_flag and not char_flag:
            first_char_time = time.ticks_us()
            char_flag = True
        data = uart.read()
        sys.stdout.buffer.write(data)

    if poll.poll(0):
        in_data = sys.stdin.buffer.read(1)
        if in_data:
            uart.write(in_data)
