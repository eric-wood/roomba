require 'rumba'
require 'pp'
# Sample Roomba control from keyword

r = Roomba.new('/dev/ttyACM0')
r.safe_mode
system 'stty cbreak'
$stdout.syswrite 'How now: '
while true do
  q = $stdin.sysread 4
  puts
  case q
    when "\e[A"
      puts "UP"
      r.straight(200)
      sleep(0.5)
      r.halt
    when "\e[B"
      puts "DOWN"
      r.straight(-200)
      sleep(0.5)
      r.halt
    when "\e[C"
      puts "RIGHT"
      r.spin_right(200)
      sleep(0.5)
      r.halt
    when "\e[D"
      puts "LEFT"
      r.spin_left(200)
      sleep(0.5)
      r.halt
    when "s"
      pp r.get_sensors
    when "v"
      r.start_all_motors
    when "z"
      r.stop_all_motors
    when "q"
      r.halt
      r.stop_all_motors
      break
  end
end
system 'stty cooked'
r.power_off
