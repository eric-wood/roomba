# Define the Rumba "DSL"
# Lots of easy to use methods for basic tasks

class Rumba
  module Dsl
    # Remember, Roomba speeds are defined in mm/s (max is 200)
    DEFAULT_SPEED = 200

    # Radius of an average Roomba, used for calculating rotation
    RADIUS = 165.1 # 6.5 inches
    
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
          direction = -90
        when :right
          direction = 90
      end

      circumfrence = 2 * Math::PI * RADIUS

      # based on the angle, this is how far we need to turn
      distance = ((circumfrence / 360) * direction).abs

      direction < 0 ? spin_left(speed) : spin_right(speed)
      duration = (distance / speed).abs
      sleep(duration)
      halt
    end

    # MEASUREMENT HELPERS
    # TODO: break these out into separate helpers file?
    def inches(num)
      25.4 * num
    end
    alias_method :inch, :inches

    def feet(num)
      inches(num) * 12
    end
    alias_method :foot, :feet

    def meters(num)
      num * 1000
    end
    alias_method :meter, :meters

    # eh, why not?
    alias_method :forwards, :forward
    alias_method :backwards, :backward
    alias_method :turn, :rotate
  end
end
