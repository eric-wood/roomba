require 'rubygems'
require 'serialport'
require 'timeout'

module RoombaSensor
  class Boolean
    def self.convert(v)
      v==1 ? true : false
    end
  end

  class ChargingState
    def self.convert(v)
      case v
        when 0
          :not_charging
        when 1
          :reconditioning_charging
        when 2
          :full_charging
        when 3
          :trickle_charging
        when 4
          :waiting
        when 5
          :charging_fault_condition
      end
    end
  end

  class OIMode
    def self.convert(v)
      case v
        when 0
          :off
        when 1
          :passive
        when 2
          :safe
        when 3
          :full
      end
    end
  end

  class ChargingSourceAvailable
    def self.convert(v)
      h={}
      h[:internal_charger]=v & 0b1 > 0 ? true : false
      h[:home_base]=v & 0b10 > 0 ? true : false
      h
    end
  end

  class LightBumper
    def self.convert(v)
      h={}
      h[:light_bumper_left]=v & 0b1 > 0 ? true : false
      h[:light_bumper_front_left]=v & 0b10 > 0 ? true : false
      h[:light_bumper_center_left]=v & 0b100 > 0 ? true : false
      h[:light_bumper_center_right]=v & 0b1000 > 0 ? true : false
      h[:light_bumper_front_right]=v & 0b10000 > 0 ? true : false
      h[:light_bumper_right]=v & 0b100000 > 0 ? true : false
      h
    end
  end

  class WheelOvercurrents
    def self.convert(v)
      h={}
      h[:side_brush]=v & 0b1 > 0 ? true : false
      h[:main_brush]=v & 0b100 > 0 ? true : false
      h[:right_wheel]=v & 0b1000 > 0 ? true : false
      h[:left_wheel]=v & 0b10000 > 0 ? true : false
      h
    end
  end

  class BumpsAndWheelDrops
    def self.convert(v)
      h={}
      h[:bump_right]=v & 0b1 > 0 ? true : false
      h[:bump_left]=v & 0b10 > 0 ? true : false
      h[:wheel_drop_right]=v & 0b100 > 0 ? true : false
      h[:wheel_drop_left]=v & 0b1000 > 0 ? true : false
      h
    end

  end

  INFRARED_CHARACTER =
  {
      129=>:left,
      130=>:forward,
      131=>:right,
      132=>:spot,
      133=>:max,
      134=>:small,
      135=>:medium,
      136=>:large,
      137=>:stop,
      138=>:power,
      139=>:arc_left,
      140=>:arc_right,
      141=>:stop,
      142=>:download,
      143=>:seek_dock,
      160=>:reserved,
      161=>:force_field,
      164=>:green_buoy,
      165=>:green_buoy_and_force_field,
      168=>:red_buoy,
      169=>:red_buoy_and_force_field,
      172=>:red_and_green_buoy,
      173=>:red_and_green_buoy_and_force_field,
      240=>:reserved,
      248=>:red_buoy,
      244=>:green_buoy,
      242=>:force_field,
      252=>:red_and_green_buoy,
      250=>:red_buoy_and_force_field,
      246=>:green_buoy_and_force_field,
      254=>:red_and_green_buoy_and_force_field,
      162=>:virtual_wall
  }


  class InfraredCharacter
    def self.convert(v)
      INFRARED_CHARACTER[v]
    end
  end
end


class Roomba
  attr_accessor :serial
  # These opcodes require no arguments
  OPCODES = {
    :start       => 128,
    :control     => 130,
    :power       => 133,
    :spot        => 134,
    :clean       => 135,
    :max         => 136,
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
  MOTORS       = 138
  LEDS         = 139
  SONG         = 140
  PLAY_SONG    = 141
  SENSORS      = 142
  QUERY_LIST      = 149
  DRIVE_DIRECT = 145
  
  # Used for making the Roomba sing!
  # Note that nil is simply a rest
  NOTES = {
    'A'  => 69, 'A#' => 70, 'B'  => 71, 'C'  => 72, 'C#' => 73, 'D'  => 74,
    'D#' => 75, 'E'  => 76, 'F'  => 77, 'F#' => 78, 'G'  => 79, 'G#' => 80,
    nil => 0
  }

  MOTORS_MASK_SIDE_BRUSH = 0x1
  MOTORS_MASK_VACUUM     = 0x2
  MOTORS_MASK_MAIN_BRUSH = 0x4

  SENSORS_PACKETS_SIZE =
    [
        0, # 0
        0,0,0,0,0,0, # 1-6
        1,1,1,1,1,1,1,1,1,1,1,1, # 7-18
        2,2, # 19-20
        1, # 21
        2,2, # 22-23
        1, # 24
        2,2,2,2,2,2,2, # 25-31
        1, # 32
        2, # 33
        1,1,1,1,1, # 34-38
        2,2,2,2,2,2, # 39-44
        1, # 45
        2,2,2,2,2,2, # 46-51
        1,1, # 52-53
        2,2,2,2, # 54-57
        1 # 58
    ]

  SENSORS_PACKETS_SIGNEDNESS =
    [
        :na, # 0
        :na,:na,:na,:na,:na,:na, # 1-6
        :unsigned,:unsigned,:unsigned,:unsigned,:unsigned,:unsigned,:unsigned,:unsigned, # 7-14
        :signed,:signed,:unsigned,:unsigned, # 15-18
        :signed,:signed, # 19-20
        :unsigned, # 21
        :unsigned,:signed, # 22-23
        :signed, # 24
        :unsigned,:unsigned,:unsigned,:unsigned,:unsigned,:unsigned,:unsigned, # 25-31
        :unsigned, # 32
        :unsigned, # 33
        :unsigned,:unsigned,:unsigned,:unsigned,:unsigned, # 34-38
        :signed,:signed,:signed,:signed,:unsigned,:unsigned, # 39-44
        :unsigned, # 45
        :unsigned,:unsigned,:unsigned,:unsigned,:unsigned,:unsigned, # 46-51
        :unsigned,:unsigned, # 52-53
        :signed,:signed,:signed,:signed, # 54-57
        :unsigned # 58
    ]

  # Human readable packets name
  SENSORS_PACKETS_SYMBOL =
  [
      :ignore, # 0
      :ignore,:ignore,:ignore,:ignore,:ignore,:ignore, # 1-6
      :bumps_and_wheel_drops,:wall,:cliff_left,:cliff_front_left,:cliff_front_right,:cliff_right,:virtual_wall,:wheel_overcurrents, # 7-14
      :dirt_detect,:ignore,:infrared_character_omni,:buttons,# 15-18
      :distance,:angle, # 19-20
      :charging_state, # 21
      :voltage,:current, # 22-23
      :temperature, # 24
      :battery_charge,:battery_capacity,:wall_signal,:cliff_left_signal,:cliff_front_left_signal,:cliff_front_right_signal,:cliff_right_signal, # 25-31
      :ignore, # 32
      :ignore, # 33
      :charging_sources_available,:oi_mode,:song_number,:song_playing,:number_of_stream_packets, # 34-38
      :requested_velocity,:requested_radius,:requested_right_velocity,:requested_left_velocity,:right_encoder_count,:left_encoder_count, # 39-44
      :light_bumper, # 45
      :light_bump_left_signal,:light_bump_front_left_signal,:light_bump_center_left_signal,:light_bump_center_right_signal,:light_bump_front_right_signal,:light_bump_right_signal, # 46-51
      :infrared_character_left,:infrared_character_right, # 52-53
      :left_motor_current,:right_motor_current,:main_brush_motor_current,:side_brush_motor_current, # 54-57
      :stasis # 58
  ]

      # Sensors mapper
  SENSORS_PACKETS_VALUE =
  {
      :wall=>RoombaSensor::Boolean,
      :cliff_left=>RoombaSensor::Boolean,
      :cliff_front_left=>RoombaSensor::Boolean,
      :cliff_front_right=>RoombaSensor::Boolean,
      :cliff_right=>RoombaSensor::Boolean,
      :virtual_wall=>RoombaSensor::Boolean,
      :song_playing=>RoombaSensor::Boolean,
      :stasis=>RoombaSensor::Boolean,

      :charging_state=>RoombaSensor::ChargingState,
      :oi_mode=>RoombaSensor::OIMode,
      :charging_sources_available=>RoombaSensor::ChargingSourceAvailable,
      :light_bumper=>RoombaSensor::LightBumper,
      :wheel_overcurrents=>RoombaSensor::WheelOvercurrents,
      :bumps_and_wheel_drops=>RoombaSensor::BumpsAndWheelDrops,
      :infrared_character_omni=>RoombaSensor::InfraredCharacter,
      :infrared_character_left=>RoombaSensor::InfraredCharacter,
      :infrared_character_right=>RoombaSensor::InfraredCharacter
  }

  # Sensors groups
  SENSORS_GROUP_PACKETS =
  {
      0=>7..26,
      1=>7..16,
      2=>17..20,
      3=>21..26,
      4=>27..34,
      5=>35..42,
      6=>7..42,
      100=>7..58,
      101=>43..58,
      106=>40..51,
      107=>54..58
  }

  #############################################################################
  # HELPERS                                                                   # 
  #############################################################################
  
  # Converts input data (an array) into bytes before
  # sending it over the serial connection.
  def write_chars(data)
    data.map! do |c|
      if c.class == String
        result = c.bytes.to_a.map { |b| [b].pack("C") }
      else
        result = [c].pack("C")
      end
      
      result
    end
    
    data = data.flatten.join
    
    @serial.write(data)
    @serial.flush
  end

  # Write data then read response
  def write_chars_with_read(data)
    data.map! do |c|
      if c.class == String
        result = c.bytes.to_a.map { |b| [b].pack("C") }
      else
        result = [c].pack("C")
      end
      
      result
    end
    
    data = data.flatten.join
    
    @serial.write(data)
    sleep(0.1)
    data=""
    while(data.length==0)
      data+=@serial.read
    end
    data
  end

  # Convert sensors bytes to packets hash
  def sensors_bytes_to_packets(bytes,packets)
    packets_h={}
    pack=""
    packets.each do |packet|
      size=SENSORS_PACKETS_SIZE[packet]
      signedness=SENSORS_PACKETS_SIGNEDNESS[packet]
      case size
        when 1
          case signedness
            when :signed
              pack+="c"
            when :unsigned
              pack+="C"
          end
        when 2
          case signedness
            when :signed
              pack+="s>"
            when :unsigned
              pack+="S>"
          end
      end
    end
    nums=bytes.unpack(pack)

    cur_packet=0
    packets.each do |packet|
      pname=SENSORS_PACKETS_SYMBOL[packet]
      unless pname==:ignore
        value=nums[cur_packet]
        conv=SENSORS_PACKETS_VALUE[pname]
        if conv
          value=conv.convert(value)
        end
        packets_h[pname]=value
#        packets_h[pname]||=0
      end
      cur_packet+=1
    end

    packets_h
  end

  # Convert integer to two's complement signed 16 bit integer.
  # Note that the Roomba is big-endian...I need to fix this
  # code to make it portable across different architectures.
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
  
  # Turn LEDs on and off
  # Arguments are a hash in the following format:
  # :advance   => true/false | sets the "advance" LED (the >> one)
  # :play      => true/false | sets the "play" LED (the > one)
  # :color     => 0-255      | sets the color of the power LED (0 = green, 255 = red)
  # :intensity => 0-255      | sets the intensity of the power LED (0 = off)
  def set_leds(args)
    @leds[:advance]   = args[:advance]   unless args[:advance].nil?
    @leds[:play]      = args[:play]      unless args[:play].nil?
    @leds[:color]     = args[:color]     unless args[:color].nil?
    @leds[:intensity] = args[:intensity] unless args[:intensity].nil?
    led_bits  = 0b00000000
    led_bits |= 0b00001000 if @leds[:advance]
    led_bits |= 0b00000010 if @leds[:play]
    
    write_chars([LEDS, led_bits, @leds[:color], @leds[:intensity]])
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

  # Get sensors by group
  # Default group 100 = all packets
  def get_sensors(group=100)
    sensors_bytes_to_packets(write_chars_with_read([SENSORS,group]),SENSORS_GROUP_PACKETS[group])
  end

  # Get sensors by list
  # Array entry can be packet ID or symbol
  def get_sensors_list(list)
    sensors_bytes_to_packets(write_chars_with_read([QUERY_LIST,group]),list.map do |l|
      if l.class==Symbol
        SENSORS_PACKETS_SYMBOL.find_index(l)
      else
        l
      end
    end)
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

  def battery_percentage
    sensors=get_sensors(3)
    ((sensors[:battery_charge].to_f/sensors[:battery_capacity].to_f) * 100).to_i
  end

  def stop_all_motors
    write_chars([MOTORS,0])
  end

  def start_all_motors
    write_chars([MOTORS,MOTORS_MASK_SIDE_BRUSH|MOTORS_MASK_VACUUM|MOTORS_MASK_MAIN_BRUSH])
  end

  def start_side_brush_motor
    write_chars([MOTORS,MOTORS_MASK_SIDE_BRUSH])
  end

  def start_vacumm_motor
    write_chars([MOTORS,MOTORS_MASK_VACUUM])
  end

  def start_main_brush_motor
    write_chars([MOTORS,MOTORS_MASK_MAIN_BRUSH])
  end

  def initialize(port, timeout=10)
    @leds = {
      :advance   => false,
      :play      => false,
      :color     => 0,
      :intensity => 0
    }
    
    @timeout = timeout
    Timeout::timeout(@timeout) do
      # Initialize the serialport
      # 115200 for Roomba 5xx
      # 57600 for older models ?
      @serial = SerialPort.new(port, 115200)
      @serial.read_timeout = 1000
      self.start
    end
  end
end

