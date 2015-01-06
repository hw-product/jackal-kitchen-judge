$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)) + '/lib/'
require 'jackal-kitchen-judge/version'
Gem::Specification.new do |s|
  s.name = 'jackal-kitchen-judge'
  s.version = Jackal::KitchenJudge::VERSION.version
  s.summary = 'Jackal Kitchen Judge'
  s.author = 'Heavywater'
  s.email = 'support@hw-ops.com'
  s.homepage = 'http://github.com/heavywater/jackal-kitchen-judge'
  s.description = 'Jackal Kitchen Judge'
  s.require_path = 'lib'
  s.add_dependency 'jackal'
  s.files = Dir['**/*']
end
