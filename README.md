# roomba
A Ruby wrapper for the Roomba Serial Command Interface

- - -

In my quest to do everything in Ruby, I was shocked to discover there was no Ruby gem or library for interacting with the iRobot Roomba! *gasp*

Something had to be done. And this is that something.

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
* Add support for all Roomba SCI commands
* Create an optional DSL

### More Information

The complete Roomba SCI specification can be found [here](http://www.irobot.com/images/consumer/hacker/roomba_sci_spec_manual.pdf)

### License

```
Copyright (c) 2012, Eric Wood
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
