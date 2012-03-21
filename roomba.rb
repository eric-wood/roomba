require 'rubygems'
require 'serialport'

class Roomba
  # These opcodes require no arguments
  OPCODES = {
    :start => 128,
    :control => 130,
    :safe_mode => 131,
    :full_mode => 132,
  }

  # These opcodes require arguments
  DRIVE = 137

  def write_chars(data);
    data.each do |c|
      c = [c].pack("C")
      @serial.putc(c)
    end
    @serial.flush
  end

  def write_raw(data)
    @data.each { |c| @serial.putc(c) }
    @serial.flush
  end

  # Convert an integer into a value the roomba can use;
  # it requires signed 16 bit integers, with the bytes flipped
  def convert_int(int)
    [int].pack('s').reverse
  end

  def drive(velocity, radius)
    velocity = convert_int(velocity)
    radius   = convert_int(radius)
    write_chars([DRIVE, velocity, radius])
  end

  def start
    write_chars([START])
  end

  def control; write_chars([CONTROL]); end

  def full_mode
    write_chars([CONTROL,FULL_MODE])
    sleep(0.2)
  end

  def power_off
    @serial.close
  end

  def initialize(port)
    # Initialize the serialport
    @serial = SerialPort.new(port, 57600)
    @serial.read_timeout = 1000
    self.start
  end

end

roomba = Roomba.new('/dev/tty.SerialIO1-SPP')
roomba.full_mode
roomba.drive(250,0)
roomba.power_off
