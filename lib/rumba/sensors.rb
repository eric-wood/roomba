# Sensor-related code is all here!

class Rumba
  module Sensor
    class Boolean
      def self.convert(v)
        v == 1
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
        h = {}
        h[:internal_charger] = v & 0b01 > 0
        h[:home_base]        = v & 0b10 > 0
        h
      end
    end

    class LightBumper
      def self.convert(v)
        h = {}
        h[:light_bumper_left]         = v & 0b000001 > 0
        h[:light_bumper_front_left]   = v & 0b000010 > 0
        h[:light_bumper_center_left]  = v & 0b000100 > 0
        h[:light_bumper_center_right] = v & 0b001000 > 0
        h[:light_bumper_front_right]  = v & 0b010000 > 0
        h[:light_bumper_right]        = v & 0b100000 > 0
        h
      end
    end

    class WheelOvercurrents
      def self.convert(v)
        h = {}
        h[:side_brush]  = v & 0b00001 > 0
        h[:main_brush]  = v & 0b00100 > 0
        h[:right_wheel] = v & 0b01000 > 0
        h[:left_wheel]  = v & 0b10000 > 0
        h
      end
    end

    class BumpsAndWheelDrops
      def self.convert(v)
        h = {}
        h[:bump_right]       = v & 0b0001 > 0
        h[:bump_left]        = v & 0b0010 > 0
        h[:wheel_drop_right] = v & 0b0100 > 0
        h[:wheel_drop_left]  = v & 0b1000 > 0
        h
      end
    end

    INFRARED_CHARACTER = {
      129 => :left,
      130 => :forward,
      131 => :right,
      132 => :spot,
      133 => :max,
      134 => :small,
      135 => :medium,
      136 => :large,
      137 => :stop,
      138 => :power,
      139 => :arc_left,
      140 => :arc_right,
      141 => :stop,
      142 => :download,
      143 => :seek_dock,
      160 => :reserved,
      161 => :force_field,
      164 => :green_buoy,
      165 => :green_buoy_and_force_field,
      168 => :red_buoy,
      169 => :red_buoy_and_force_field,
      172 => :red_and_green_buoy,
      173 => :red_and_green_buoy_and_force_field,
      240 => :reserved,
      248 => :red_buoy,
      244 => :green_buoy,
      242 => :force_field,
      252 => :red_and_green_buoy,
      250 => :red_buoy_and_force_field,
      246 => :green_buoy_and_force_field,
      254 => :red_and_green_buoy_and_force_field,
      162 => :virtual_wall
    }

    class InfraredCharacter
      def self.convert(v)
        INFRARED_CHARACTER[v]
      end
    end

    SENSOR_PACKET_SIZE = [
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

    SENSOR_PACKET_SIGNEDNESS = [
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

    # Human readable packet names
    SENSOR_SYMBOLS = [
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

    # Sensor mapper
    SENSOR_PACKET_VALUE = {
      wall:                       Boolean,
      cliff_left:                 Boolean,
      cliff_front_left:           Boolean,
      cliff_front_right:          Boolean,
      cliff_right:                Boolean,
      virtual_wall:               Boolean,
      song_playing:               Boolean,
      stasis:                     Boolean,

      charging_state:             ChargingState,
      oi_mode:                    OIMode,
      charging_sources_available: ChargingSourceAvailable,
      light_bumper:               LightBumper,
      wheel_overcurrents:         WheelOvercurrents,
      bumps_and_wheel_drops:      BumpsAndWheelDrops,
      infrared_character_omni:    InfraredCharacter,
      infrared_character_left:    InfraredCharacter,
      infrared_character_right:   InfraredCharacter
    }

    # Sensors groups
    SENSORS_GROUP_PACKETS = {
      0   => 7..26,
      1   => 7..16,
      2   => 17..20,
      3   => 21..26,
      4   => 27..34,
      5   => 35..42,
      6   => 7..42,
      100 => 7..58,
      101 => 43..58,
      106 => 40..51,
      107 => 54..58
    }

    # Convert sensors bytes to packets hash
    def sensor_bytes_to_packets(bytes, packets)
      # template string for unpacking the data
      pack = ''
      packets.each do |packet|
        size = SENSOR_PACKET_SIZE[packet]
        signedness = SENSOR_PACKET_SIGNEDNESS[packet]
        case size
        when 1 # 8 bit (big endian)
          case signedness
          when :signed
            pack << 'c'
          when :unsigned
            pack << 'C'
          end
        when 2 # 16 bit (big endian)
          case signedness
          when :signed
            pack << 's>'
          when :unsigned
            pack << 'S>'
          end
        end
      end

      data = bytes.unpack(pack)

      results = {}
      packets.each_with_index do |packet,index|
        packet_name = SENSOR_SYMBOLS[packet]
        unless packet_name == :ignore
          value = data[index]

          # map to native Ruby type
          converter = SENSOR_PACKET_VALUE[packet_name]
          value = converter.convert(value) if converter

          results[packet_name] = value
        end
      end

      results
    end

    # Get sensors by group
    # Default group 100 = all packets
    def get_sensors(group=100)
      raw_data = write_chars_with_read([Constants::SENSORS,group])
      sensor_bytes_to_packets(raw_data, SENSORS_GROUP_PACKETS[group])
    end

    # Get sensors by list
    # Array entry can be packet ID or symbol
    def get_sensors_list(sensors)
      # convert from symbols to IDs
      sensors.map! do |sensor|
        if sensor.class == Symbol
          SENSOR_SYMBOLS.find_index(sensor)
        else
          sensor
        end
      end

      # request sensor data!
      request = [Constants::QUERY_LIST, sensors.length] + sensors
      write_chars(request)

      raw_data = ""
      sensors.each do |id|
        raw_data << @serial.read(SENSOR_PACKET_SIZE[id])
      end

      sensor_bytes_to_packets(raw_data, sensors)
    end

    # convenience method for grabbing a single sensor
    def get_sensor(sensor)
      get_sensors_list([sensor])[sensor]
    end
  end
end
