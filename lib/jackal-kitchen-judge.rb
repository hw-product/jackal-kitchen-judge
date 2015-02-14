require 'jackal'
require 'jackal-kitchen-judge/version'
require 'jackal-kitchen-judge/formatter/slack_message'


module Jackal
  module KitchenJudge
    autoload :Adjudicate, 'jackal-kitchen-judge/adjudicate'
  end
end
