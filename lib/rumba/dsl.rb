# Define the Rumba "DSL"
# Lots of easy to use methods for basic tasks

class Rumba
  module Dsl
    # Remember, Roomba speeds are defined in mm/s (max is 200)
    DEFAULT_SPEED = 200

    # Radius of an average Roomba, used for calculating rotation
    RADIUS = 165.1 # 6.5 inches

    # move both wheels at the same speed in a certain direction!
    # NOTE THAT THIS BLOCKS UNTIL COMPLETE
    def straight_distance(distance, speed: DEFAULT_SPEED)
      total = 0
      straight(speed)
      loop do
        total += get_sensor(:distance).abs
        break if total >= distance
      end

      halt
    end
    
    # distance is in mm!
    def forward(distance, speed: DEFAULT_SPEED)
      straight_distance(distance, speed: speed)
    end

    # distance is in mm!
    def backward(distance, speed: DEFAULT_SPEED)
      straight_distance(distance, speed: -speed)
    end

    # Direction can either be a Fixnum for number of degrees,
    # or a symbol for the direction (:left, :right)
    def rotate(direction, speed: DEFAULT_SPEED)
      # handle symbols...
      # note that counter-clockwise is positive
      case direction
        when :left
          direction = 90
        when :right
          direction = -90
      end

      direction > 0 ? spin_right(speed) : spin_left(speed)

      total = 0
      goal  = direction.abs / 2
      loop do
        raw_angle = get_sensor(:angle)

        # taken from the official docs to convert output to degrees...
        degrees = (360 * raw_angle)/(258 * Math::PI)
        total += degrees.abs
        break if total >= goal
      end

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
