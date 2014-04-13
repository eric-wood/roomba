require 'roomba'

# Sample Roomba control from keyword

r = Roomba.new('/dev/ttyACM0')
r.safe_mode
system 'stty cbreak'
$stdout.syswrite 'How now: '
while(1) do
q = $stdin.sysread 4
puts
case q
when "\e[A"
puts "UP"
r.straight(100)
sleep(0.5)
r.halt
when "\e[B"
puts "DOWN"
r.straight(-100)
sleep(0.5)
r.halt
when "\e[C"
puts "RIGHT"
r.spin_right(100)
sleep(0.5)
r.halt
when "\e[D"
puts "LEFT"
r.spin_left(100)
sleep(0.5)
r.halt
when "q"
r.halt
break
end
end
system 'stty cooked'
r.power_off
