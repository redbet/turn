require 'turn/reporters/pretty_reporter'

module Turn
  # = Timing Reporter (by jonasbro)
  #
  # Example output:
  # Longest running suites, (total time, avg time, no of tests)
  #
  #   TestBetradarLiveMarkets (8.636, 0.288, 30)
  #
  # Longest running tests
  #
  #   test_map_selections_for_home_and_away_even_if_market_already_exists (0.370)
  #   test_spawn_Away_Exact_Goals_market_on_odds_update (0.359)
  #
  class TimingReporter < PrettyReporter
    def initialize(io, opts={})
      super
      @test_times, @case_times = [], []
    end

    def start_case(kase)
      super
      @case_time = Time.now
    end

    def finish_case(kase)
      super

      tests = kase.count_tests
      return if tests < 1

      time = Time.now - @case_time
      @case_times << [kase.name, time, tests, time / tests.to_f]
    end

    def start_test(test)
      super
      @test_time = Time.now
    end

    def finish_test(test)
      super
      @test_times << [test.name, Time.now - @test_time]
    end

    def finish_suite(suite)
      output_test_times @case_times, "Longest running suites, (total time, avg time, no of tests)"
      output_test_times @test_times, "Longest running tests"

      super
    end

    private

    def output_test_times(times, msg)
      io.puts msg
      io.puts
      times.sort_by { |e| e.last }.reverse[0, 10].each do |name, tot, num, avg|
        s = "\t#{name} (#{"%.3f" % tot}"
        s << ", #{"%.3f" % avg}, " if avg
        s << num.to_s              if num
        s << ")"
        io.puts s
      end
      io.puts
    end
  end
end
