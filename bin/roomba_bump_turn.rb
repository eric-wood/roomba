require 'rumba'

# Sample Roomba bump & turn

speed = ARGV[0]
speed = speed ? speed.to_i : 200

Rumba.new('/dev/tty.usbserial') do
  safe_mode
  start_all_motors

  loop do
    bumps = get_sensor(:bumps_and_wheel_drops)

    if bumps[:bump_left]
      halt
      sleep 0.1
      spin_right(speed)
      sleep 1
      halt
      sleep 0.1
    else
      if bumps[:bump_right]
        halt
        sleep 0.1
        spin_left(speed)
        sleep 1
        halt
        sleep 0.1
      end
    end

    if bumps[:wheel_drop_right] | bumps[:wheel_drop_left]
      halt
    else
      straight(speed)
    end

    sleep 0.1
  end
end
