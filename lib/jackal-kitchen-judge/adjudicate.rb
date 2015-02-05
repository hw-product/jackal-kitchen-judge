require "jackal-kitchen-judge"

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
          payload.get(:data, :kitchen, :test_output)
        end
      end

      def execute(msg)
        failure_wrap(msg) do |payload|
          payload[:data][:kitchen][:judge] = Smash.new
          verdict = adjudicate(payload)
          payload[:data][:kitchen][:judge][:decision] = verdict[:decision]
          payload[:data][:kitchen][:judge][:reasons] = verdict[:reasons]
          job_completed(:kitchen_judge, payload, msg)
        end
      end

      # payload:: Payload
      # Return true if tests passed
      def adjudicate(payload)
        teapot_data = teapot_metadata(payload.get(:data, :kitchen, :test_output, :teapot))
        chefspec_data = spec_metadata(payload.get(:data, :kitchen, :test_output, :chefspec), :chefspec)
        serverspec_data = spec_metadata(payload.get(:data, :kitchen, :test_output, :serverspec), :serverspec)
        payload[:data][:kitchen][:judge][:teapot] = teapot_data

        judgement = { :reasons => [] }

        judgement[:reasons] << :teapot_runtime if teapot_data[:total_runtime][:threshold_exceeded]

        rspec_result = payload.get(:data, :kitchen, :result, "bundle exec rspec")
        kitchen_result = payload.get(:data, :kitchen, :result, "bundle exec kitchen test")

        judgement[:reasons] << :rspec unless rspec_result.to_s == "success"
        judgement[:reasons] << :kitchen unless kitchen_result.to_s == "success"

        judgement[:decision] = judgement[:reasons].empty?

        judgement
      end

      def teapot_metadata(data) # data,kitchen,test_output,teapot ->  #return hash
        # TODO :transient_failures => [],

        duration = data["timing"].map { |d|d["time"] }.inject(:+)

        exceeded = duration > config.fetch(
                     :kitchen, :thresholds, :teapot, :total_runtime, 600
                   )

        total_runtime = { :duration => duration,
                          :threshold_exceeded => exceeded }

        sorted_resources = data["timing"].sort_by{ |x|x["time"] }
        slowest_resource = sorted_resources.last

        resources_over_threshold = sorted_resources.reject { |r|
          r["time"] < config.fetch(
            :kitchen, :thresholds, :teapot, :resource_runtime, 120
          )
        }

        { :slowest_resource => slowest_resource,
          :resources_over_threshold => resources_over_threshold,
          :total_runtime => total_runtime }
      end

      def spec_metadata(data, format)
        duration = data["summary"]["duration"]
        sorted_tests = data["examples"].sort_by{ |x|x["run_time"] }
        slowest_test = sorted_tests.last
        tests_over_threshold = []
        threshold = config.fetch(:kitchen, :thresholds, format, :test_runtime, 60)

        tests_over_threshold = data["examples"].reject { |e|
          if e.key?("run_time")
            e["run_time"] < threshold
          end
        }

        { :slowest_test => slowest_test,
          :tests_over_threshold => tests_over_threshold,
          :total_runtime => duration }
      end

    end
  end
end
