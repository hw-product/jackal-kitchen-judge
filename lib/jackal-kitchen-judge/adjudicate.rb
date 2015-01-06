require 'jackal-kitchen-judge'

module Jackal
  # Formulate kitchen output into short message
  module KitchenJudge
    class Adjudicate < Jackal::Callback

      def setup(*_)
      end

      # Validity of payload
      #
      # @param message [Carnivore::Message]
      # @return [Truthy, Falsey]
      def valid?(message)
        super do |payload|
          payload.get(:data, :kitchen)
        end
      end

      def execute(msg)
        failure_wrap(msg) do |payload|
          payload[:data][:kitchen][:judge] = Smash.new
          payload[:data][:kitchen][:judge][:judgement] = adjudicate(payload)
          job_completed(:kitchen_judge, payload, msg)
        end
      end

      # payload:: Payload
      # Return true if tests passed
      def adjudicate(payload)
        rspec_result = payload.get(:data, :kitchen, :result, 'bundle exec rspec')
        kitchen_result = payload.get(:data, :kitchen, :result, 'bundle exec kitchen test')
        if rspec_result == :success && kitchen_result == :success
          return true
        else
          return false
        end
      end

    end
  end
end
