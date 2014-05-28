module RoombaSensor
  class Boolean
    def self.convert(v)
      v == 1 ? true : false
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
      h[:internal_charger] = v & 0b1 > 0  ? true : false
      h[:home_base]        = v & 0b10 > 0 ? true : false
      h
    end
  end

  class LightBumper
    def self.convert(v)
      h = {}
      h[:light_bumper_left]         = v & 0b1 > 0      ? true : false
      h[:light_bumper_front_left]   = v & 0b10 > 0     ? true : false
      h[:light_bumper_center_left]  = v & 0b100 > 0    ? true : false
      h[:light_bumper_center_right] = v & 0b1000 > 0   ? true : false
      h[:light_bumper_front_right]  = v & 0b10000 > 0  ? true : false
      h[:light_bumper_right]        = v & 0b100000 > 0 ? true : false
      h
    end
  end

  class WheelOvercurrents
    def self.convert(v)
      h = {}
      h[:side_brush]  = v & 0b1     > 0 ? true : false
      h[:main_brush]  = v & 0b100   > 0 ? true : false
      h[:right_wheel] = v & 0b1000  > 0 ? true : false
      h[:left_wheel]  = v & 0b10000 > 0 ? true : false
      h
    end
  end

  class BumpsAndWheelDrops
    def self.convert(v)
      h = {}
      h[:bump_right]       = v & 0b1 > 0    ? true : false
      h[:bump_left]        = v & 0b10 > 0   ? true : false
      h[:wheel_drop_right] = v & 0b100 > 0  ? true : false
      h[:wheel_drop_left]  = v & 0b1000 > 0 ? true : false
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
end

