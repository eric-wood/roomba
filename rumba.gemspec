Gem::Specification.new do |s|
  s.name        = 'rumba'
  s.version     = '0.2.6'
  s.date        = '2014-08-26'
  s.summary     = 'Ruby bindings for the iRobot Roomba'
  s.description = 'Control your Roomba using Ruby!'
  s.authors     = ['Eric Wood']
  s.email       = 'eric@ericwood.org'
  s.files       = Dir["lib/**/*.rb", "README.md", "LICENSE"]
  s.homepage    = 'http://github.com/eric-wood/roomba'
  s.license     = 'BSD'

  s.add_runtime_dependency 'serialport', ['>= 0']
end
