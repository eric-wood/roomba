# rumba
A Ruby wrapper for the Roomba Serial Command Interface

- - -

In my quest to do everything in Ruby, I was shocked to discover there was no Ruby gem or library for interacting with the iRobot Roomba! *gasp*

Something had to be done. And this is that something.

### Dependencies
* [serialport](http://ruby-serialport.rubyforge.org/)

### Usage

Here's an example program:
```ruby
require_relative 'roomba.rb'
r = Roomba.new('/dev/tty.SerialIO1-SPP')
r.full_mode       # Change to full mode (unrestricted access)
r.straight(300)   # Move forwards at 300 mm/s
sleep(2)
r.straight(-300)  # Move backwards at 300 mm/s
sleep(2)
r.spin_left(500)  # Spin to the left at 500 mm/s
sleep(2)
r.spin_right(500) # Spin to the right at 500 mm/s
r.halt            # Stop moving
```

### Roadmap
* Add support for all Roomba SCI commands
* Package this into a gem!
* Create an optional DSL

### More Information

The complete Roomba SCI specification can be found [here](http://www.irobot.com/images/consumer/hacker/roomba_sci_spec_manual.pdf)

### License
##### "THE BEER-WARE LICENSE" (Revision 42):
[Eric Wood](http://ericwood.org) wrote this file. As long as you retain this notice you<br/>
can do whatever you want with this stuff. If we meet some day, and you think<br>
this stuff is worth it, you can buy me a beer in return.
