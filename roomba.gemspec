Gem::Specification.new do |s|
  s.name        = 'roomba'
  s.version     = '0.1.0'
  s.date        = '2013-08-05'
  s.summary     = 'Ruby bindings for the iRobot Roomba'
  s.description = 'Control your Roomba using Ruby!'
  s.authors     = ['Eric Wood']
  s.email       = 'eric@ericwood.org'
  s.files       = ['lib/roomba.rb']
  s.homepage    = 'http://github.com/eric-wood/roomba'
  s.license     = 'BSD'

  s.add_runtime_dependency 'serialport', ['>= 0']
end
