require 'roomba'

# Sample Roomba bump & turn

speed=ARGV[0]

if speed
  speed=speed.to_i
else
  speed=200
end

r = Roomba.new('/dev/ttyACM0')
r.safe_mode
r.start_all_motors

begin
  while true do
    bumps=r.get_sensors_list([:bumps_and_wheel_drops])[:bumps_and_wheel_drops]
    if bumps[:bump_left]
      r.halt
      sleep 0.1
      r.spin_right(speed)
      sleep 1
      r.halt
      sleep 0.1
    else
      if bumps[:bump_right]
        r.halt
        sleep 0.1
        r.spin_left(speed)
        sleep 1
        r.halt
        sleep 0.1
      end
    end

    if bumps[:wheel_drop_right]|bumps[:wheel_drop_left]
      r.halt
    else
      r.straight(speed)
    end

    sleep 0.1
  end
rescue SystemExit, Interrupt
  r.stop_all_motors
  r.halt
end