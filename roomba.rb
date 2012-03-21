require 'rubygems'
require 'serialport'

class Roomba
  # These opcodes require no arguments
  OPCODES = {
    :start       => 128,
    :control     => 130,
    :safe_mode   => 131,
    :dock        => 143,
    :play_script => 153,
    :show_script => 154,
  }
  
  # Create a method for each opcode that writes its data.
  # This allows us to simply call roomba.code,
  # and it's a cool excuse to do some metaprogramming :)
  OPCODES.each do |name,val|
    send :define_method, name do
      write_chars([val])
    end
  end
  
  FULL_MODE = 132
  
  # These opcodes require arguments
  DRIVE        = 137
  SONG         = 140
  DRIVE_DIRECT = 145

  NOTES = {
    'A'  => 69, 'A#' => 70, 'B'  => 71, 'C'  => 72, 'C#' => 73, 'D'  => 74,
    'D#' => 75, 'E'  => 76, 'F'  => 77, 'F#' => 78, 'G'  => 79, 'G#' => 80
  }
  
  #############################################################################
  # HELPERS                                                                   # 
  #############################################################################
  
  def write_chars(data);
    p data
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
  
  #############################################################################
  # COMMANDS                                                                  # 
  #############################################################################
  
  def full_mode
    safe_mode
    sleep(0.2) # TODO: is this necessary?
    write_chars([FULL_MODE])
    sleep(0.2)
  end
  
  def drive(velocity, radius)
    return false if velocity < -500 || velocity > 500
    return false if radius < -2000 || radius > 2000
    
    velocity = convert_int(velocity)
    radius   = convert_int(radius)
    write_chars([DRIVE])
    write_raw([velocity, radius])
  end
  
  def drive_direct(left, right)
    return false if left < -500  || left > 500
    return false if right < -500 || right > 500
    
    write_chars([DRIVE_DIRECT])
    write_raw([right, left])
  end
  
  #############################################################################
  # Convenience methods                                                       #
  #############################################################################
  
  def forwards(speed)
    drive(speed,0)
  end
  
  def turn_clockwise
    write_chars([0xFFFF])
  end
  
  def turn_counterclockwise
    write_chars([0x0001])
  end
  
  def halt
    drive(0,0)
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

roomba = Roomba.new(ARGV[0])
roomba.full_mode
roomba.drive(250,0)
roomba.power_off
