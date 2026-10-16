import typer
from amathyst import *  #imports all relevent libraries from amaranth
from aeromag.fpga.fpga import (
    fpga_on,
    write,
)   #imports needed libraries from fpga file
from aeromag.fpga.magnetometer import balance   #imports balance function from magnetometer file
from aeromag.mcu.mcu import read_mcu   #imports read function from mcu file

def app():
    imu = 0.0, button = 0, thermistor = 0.0, test = 0, magnet = 0.0, val = 0
    while(imu == 0.0 & button == 0 & test == 0):    #starts a recursive loop for mcu
        imu = read_mcu(1)
        button = read_mcu(1)

        if(imu != 0.0 & button != 0):
            test = 1

    while (thermistor <= val & imu <= val): #starts a test function for mcu reading
        thermistor = read_mcu(1)
        imu = read_mcu(1)

    fpga_on()
    while (True):   #creates an infinite loop to read until the battery for fpga is drained
        imu = read_mcu(2)
        thermistor = read_mcu(1)
        magnet = balance(1)
        write(imu, button, thermistor, magnet)