require 'rubygems'
require 'serialport'
require 'timeout'

class Roomba
  # These opcodes require no arguments
  OPCODES = {
    :start       => 128,
    :control     => 130,
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
  
  SAFE_MODE = 131
  FULL_MODE = 132
  
  # These opcodes require arguments
  DRIVE        = 137
  SONG         = 140
  PLAY_SONG    = 141
  DRIVE_DIRECT = 145
  
  # Used for making the Roomba sing!
  # Note that nil is simply a rest
  NOTES = {
    'A'  => 69, 'A#' => 70, 'B'  => 71, 'C'  => 72, 'C#' => 73, 'D'  => 74,
    'D#' => 75, 'E'  => 76, 'F'  => 77, 'F#' => 78, 'G'  => 79, 'G#' => 80,
    nil => 0
  }
  
  #############################################################################
  # HELPERS                                                                   # 
  #############################################################################
  
  # Converts input data (an array) into bytes before
  # sending it over the serial connection.
  def write_chars(data);
    data.map! do |c|
      #[c].pack("C") unless c.class == String
      if c.class == String
        result = c.bytes.to_a.map { |b| [b].pack("C") }
      else
        result = [c].pack("C")
      end
      
      result
    end
    
    data = data.flatten.join

    @serial.write(data)
    p data
    @serial.flush
  end
  
  # Pushes all data in the array over the serial connection.
  # NOTE: write_chars will do the same thing, only way better
  #def write_raw(data)
  #  p data
  #  data.each { |c| @serial.putc(c) }
  #  @serial.flush
  #end
  
  # Convert integer to two's complement signed 16 bit integer
  # it requires signed 16 bit integers, with the bytes flipped
  def convert_int(int)
    [int].pack('s').reverse
  end
  
  #############################################################################
  # COMMANDS                                                                  # 
  #############################################################################

  def safe_mode
    write_chars([SAFE_MODE])
    sleep(0.2)
  end
  
  def full_mode
    safe_mode
    write_chars([FULL_MODE])
    sleep(0.2)
  end
  
  def drive(velocity, radius)
    raise RangeError if velocity < -500 || velocity > 500
    raise RangeError if (radius < -2000 || radius > 2000) && radius != 0xFFFF
    
    velocity = convert_int(velocity)
    radius   = convert_int(radius)
    write_chars([DRIVE, velocity, radius])
  end
  
  def drive_direct(left, right)
    raise RangeError if left < -500  || left > 500
    raise RangeError if right < -500 || right > 500
    
    left  = convert_int(left)
    right = convert_int(right)
    
    write_chars([DRIVE_DIRECT])
    write_raw([right, left])
  end
  
  # Songs are cool. Here's the format:
  # The song number designates which song this is so you can recall it later.
  # The notes are specified in the NOTES hash, and are fed into the program
  # as a 2D array, where the first element is the note number and the second
  # is the duration of the note. The duration is specified in seconds.
  # Example:
  # [[note1,5], [note2,6]]
  def song(song_number, notes)
    raise RangeError if song_number < 0 || song_number > 15
    
    notes.map! { |n| [NOTES[n[0]],n[1]*64] }
    # The protocol requires us to send the number of notes and the song number first
    write_chars([SONG, song_number, notes.size] + notes.flatten)
  end
  
  def play_song(song_number)
    raise RangeError if song_number < 0 || song_number > 15
    write_chars([PLAY_SONG,song_number])
  end
  
  #############################################################################
  # Convenience methods                                                       #
  #############################################################################
  
  def straight(speed)
    speed = convert_int(speed)
    write_chars([DRIVE,speed,convert_int(32768)])
  end
  
  def spin_left(speed)
    speed = convert_int(speed)
    write_chars([DRIVE,speed,convert_int(1)])
  end
  
  def spin_right(speed)
    speed = convert_int(speed)
    write_chars([DRIVE,speed,convert_int(-1)])
  end
  
  def lights
    write_chars([139,9,0,128])
  end
  
  def halt
    drive(0,0)
  end
  
  def power_off
    @serial.close
  end
  
  def hullaballoo
    whoop = [['E',0.2],['E',0.2],['E',0.2],['E',0.2],[nil,0.2],['E',0.2],['E',0.2],[nil,0.2],['E',0.2],['E',0.2]]
    song(0, whoop)
    play_song(0)
  end
  
  def initialize(port, timeout=10)
    @timeout = timeout
    Timeout::timeout(@timeout) do
      # Initialize the serialport
      @serial = SerialPort.new(port, 57600)
      @serial.read_timeout = 1000
      self.start
    end
  end
end

