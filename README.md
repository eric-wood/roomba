# Rumba
A Ruby wrapper for the Roomba Serial Command Interface

[![Gem Version](https://badge.fury.io/rb/rumba.svg)](http://badge.fury.io/rb/rumba)

- - -

This is a no-frills, lightweight, and cross-platform implementation of the iRobot Roomba Serial Command Interface. You can use it to control your Roomba from your computer :D

So far it supports all of the main movement functions, and a tad bit of sensor stuffs, but there are a few chunks of the API that I've left out!

Originally used as part of my senior design project in school, but now gem-ified for the handful of other people who think robots and Ruby are a good combination :)

For more serious robot hacking in Ruby, check out [Artoo](http://artoo.io/)! It's really neat, but possibly a little overkill for small hacks.

I welcome pull requests and feedback!

Happy hacking!

### Dependencies
* [serialport](http://ruby-serialport.rubyforge.org/)

### Usage

Here's an example program:

```ruby
require 'roomba.rb'
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
* Add support for all Roomba SCI commands (namely sensor reading!)
* Create an optional DSL

### More Information

The complete Roomba SCI specification can be found [here](http://www.irobot.com/images/consumer/hacker/roomba_sci_spec_manual.pdf)

### License

```
Copyright (c) 2014, Eric Wood
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the author nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL ERIC WOOD BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```
