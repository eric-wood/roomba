Gem::Specification.new do |s|
  s.name        = 'rumba'
  s.version     = '0.2.0'
  s.date        = '2014-05-27'
  s.summary     = 'Ruby bindings for the iRobot Roomba'
  s.description = 'Control your Roomba using Ruby!'
  s.authors     = ['Eric Wood']
  s.email       = 'eric@ericwood.org'
  s.files       = ['lib/rumba.rb', 'lib/sensors.rb', 'lib/constants.rb']
  s.homepage    = 'http://github.com/eric-wood/roomba'
  s.license     = 'BSD'

  s.add_runtime_dependency 'serialport', ['>= 0']
end
