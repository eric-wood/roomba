require 'rubygems'
require 'serialport'

class Roomba
  # Opcodes
  #START     = 128.chr
  #CONTROL   = 130.chr
  #SAFE_MODE = 131.chr
  #FULL_MODE = 132.chr
  #DRIVE     = 137.chr
  START     = 0x80
  CONTROL   = 0x82
  SAFE_MODE = 0x83
  FULL_MODE = 0x84
  DRIVE     = 0x89

  #def serial_write(data);
  #  p data
  #  #data.each {|c| @serial.putc(c.chr) }
  #  data.each {|c| @serial.putc(c) }
  #  @serial.flush
  #end

  def serial_write(data);
    data.map! { |i| [i].pack("C") }
    p data
    data.each {|c| @serial.putc(c) }
    @serial.flush
  end

  def drive(velocity, radius)
    #serial_write([DRIVE, velocity, radius])
    serial_write([0x89,01,0x90,80,0x00])
  end

  def initialize(port)
    # Initialize the serialport
    @serial = SerialPort.new(port, 57600)
    @serial.read_timeout = 1000
    self.start
    self.control
    self.full_mode
    sleep(0.2)
  end

  def start
    serial_write([START])
  end

  def control
    serial_write([CONTROL])
  end

  def full_mode
    serial_write([CONTROL])
    serial_write([FULL_MODE])
  end

  def quit
    @serial.close
  end
end

roomba = Roomba.new('/dev/tty.SerialIO1-SPP')
roomba.serial_write([0x80])
roomba.serial_write([0x82])
sleep(0.2)
roomba.serial_write([0x89,01,0x90,80,00])
#roomba.drive(250,0)
