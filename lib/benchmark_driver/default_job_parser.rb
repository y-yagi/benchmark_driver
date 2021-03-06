module BenchmarkDriver
  module DefaultJobParser
    # Build default JobParser for given job klass
    def self.for(klass)
      Module.new.tap do |parser|
        class << parser
          include DefaultJobParser
        end
        parser.define_singleton_method(:job_class) do
          klass
        end
      end
    end

    # This method is dynamically called by `BenchmarkDriver::JobParser.parse`
    # @param [String] prelude
    # @param [String,Array<String,Hash{ Symbol => String }>,Hash{ Symbol => String }] benchmark
    # @param [String] teardown
    # @param [Integer] loop_count
    # @param [String] required_ruby_version
    # @return [Array<BenchmarkDriver::Default::Job>]
    def parse(prelude: nil, benchmark:, teardown: nil, loop_count: nil, required_ruby_version: nil)
      parse_benchmark(benchmark).each do |job|
        job.prelude.prepend("#{prelude}\n") if prelude
        job.teardown.prepend("#{teardown}\n") if teardown
        job.loop_count ||= loop_count
        job.required_ruby_version ||= required_ruby_version
      end.each(&:freeze)
    end

    private

    # @param [String,Array<String,Hash{ Symbol => String }>,Hash{ Symbol => String }] benchmark
    def parse_benchmark(benchmark)
      case benchmark
      when String
        [parse_job(benchmark)]
      when Array
        benchmark.map { |b| parse_job(b) }
      when Hash
        benchmark.map do |key, value|
          job_class.new(name: key.to_s, script: value)
        end
      else
        raise ArgumentError.new("benchmark must be String, Array or Hash, but got: #{benchmark.inspect}")
      end
    end

    # @param [String,Hash{ Symbol => String }>] bench
    def parse_job(benchmark)
      case benchmark
      when String
        job_class.new(name: benchmark, script: benchmark)
      when Hash
        parse_job_hash(benchmark)
      else
        raise ArgumentError.new("Expected String or Hash in element of benchmark, but got: #{benchmark.inspect}")
      end
    end

    def parse_job_hash(name: nil, prelude: '', script:, teardown: '', loop_count: nil, required_ruby_version: nil)
      name ||= script
      job_class.new(name: name, prelude: prelude, script: script, teardown: teardown, loop_count: loop_count, required_ruby_version: required_ruby_version)
    end

    def job_class
      raise NotImplementedError # override this
    end
  end
end
