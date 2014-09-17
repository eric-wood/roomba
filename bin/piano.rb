# Turn the Roomba into a virtual keyboard :D
# Use keys in the middle row (asdfghjkl) to play notes!
# 0 through 9 control the octave!

require 'curses'
require 'rumba'

include Curses

# setup code for curses
def init_screen
  Curses.noecho
  Curses.stdscr.nodelay = true
  Curses.curs_set(0)
  Curses.init_screen
  Curses.stdscr.keypad(true)
  begin
    yield
  ensure
    Curses.close_screen
  end
end

NOTES = (36..127).to_a
KEYS = %w[a s d f g h j k l]
SONG_NUMBER = 1
NOTE_DURATION = 0.2

octave = 2
OCTAVES = (1..9).map(&:to_s)

roomba = Roomba.new('/dev/tty.usbserial')
roomba.safe_mode

init_screen do
  loop do
    key = Curses.getch

    if KEYS.include?(key) 
      offset = octave * KEYS.size
      note = NOTES[offset, KEYS.size][KEYS.index(key)]
      roomba.song(SONG_NUMBER, [[note, NOTE_DURATION]])
      roomba.play_song(SONG_NUMBER)
    elsif OCTAVES.include?(key)
      octave = key.to_i
    end
  end
end
