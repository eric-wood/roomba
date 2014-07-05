# Define the Rumba "DSL"
# Lots of easy to use methods for basic tasks

class Rumba
  module Dsl
    # Remember, Roomba speeds are defined in mm/s (max is 200)
    DEFAULT_SPEED = 100
    
    # distance is in mm!
    def forward(distance, speed: DEFAULT_SPEED)
      duration = distance / speed
      straight(speed)
      sleep(duration)
      halt
    end

    # distance is in mm!
    def backward(distance, speed: DEFAULT_SPEED)
      duration = distance / speed
      straight(-speed)
      sleep(duration)
      halt
    end

    # Direction can either be a Fixnum for number of degrees,
    # or a symbol for the direction (:left, :right)
    def rotate(direction, speed: DEFAULT_SPEED)
      # handle symbols...
      case direction
        when :left
          direction = -45
        when :right
          direction = 45
      end

      # TODO: issue drive commands based on calculations!
    end

    # MEASUREMENT HELPERS
    # TODO: break these out into separate helpers file?
    def inches(num)
      25.4 * num
    end

    def feet(num)
      inches(num) * 12
    end

    def meters(num)
      num * 1000
    end
  end
end
