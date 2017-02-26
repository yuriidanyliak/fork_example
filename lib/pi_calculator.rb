module ProcessForker
  class PiCalculator
    attr_reader :output_stream

    BASE_NUMBER = 4.0

    def initialize(output_stream)
      @output_stream = output_stream
    end

    def call(number_of_processes)
      spawn_process_pool(number_of_processes).each { |pid| wait_process(pid) }

      notify_about_termination

      nil
    end

    protected

    def publish_value(pi_value)
      @output_stream.puts pi_value
    end

    def notify_about_termination
      @output_stream.puts 'Successfully waited for child processes termination.'
    end

    private

    def spawn_process_pool(size)
      pids = []
      size.times { pids << spawn_process }
      pids
    end

    def spawn_process
      fork do
        pi_value = calculate_pi(10_000_000)
        publish_value(pi_value)
      end
    end

    def calculate_pi(calculations_count)
      pi = 0
      plus = true

      denominator = 1
      while denominator < calculations_count
        if plus
          pi = pi + BASE_NUMBER / denominator
          plus = false
        else
          pi = pi - BASE_NUMBER / denominator
          plus = true
        end

        denominator += 2
      end

      pi
    end

    def wait_process(pid)
      Process.waitpid(pid)
    end
  end
end
