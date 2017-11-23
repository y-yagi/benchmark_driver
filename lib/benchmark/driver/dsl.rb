require 'benchmark/driver/configuration'

class Benchmark::Driver::DSL
  def initialize(runner: :call)
    @runner = runner
    @prelude = nil
    @jobs = []
    @output_options = {}
  end

  # API to fetch configuration parsed from DSL
  # @return [Benchmark::Driver::Configuration]
  def configuration
    @jobs.each do |job|
      job.prelude = @prelude
    end
    Benchmark::Driver::Configuration.new(@jobs).tap do |c|
      c.runner = @runner
      c.output_options = @output_options
    end
  end

  # @param [String] prelude - Script required for benchmark whose execution time is not measured.
  def prelude=(prelude)
    unless prelude.is_a?(String)
      raise ArgumentError.new("prelude must be String but got #{prelude.inspect}")
    end
    unless @prelude.nil?
      raise ArgumentError.new("prelude is already set:\n#{@prelude}")
    end

    @prelude = prelude
  end

  # @param [String,nil] name   - Name shown on result output. This must be provided if block is given.
  # @param [String,nil] script - Benchmarked script in String. Only either of script or block must be provided.
  # @param [Proc,nil]   block  - Benchmarked Proc object.
  def report(name = nil, script: nil, &block)
    if script.nil? && !block_given?
      raise ArgumentError.new('script or block must be provided')
    elsif !script.nil? && block_given?
      raise ArgumentError.new('script and block cannot be specified at the same time')
    elsif name.nil? && block_given?
      raise ArgumentError.new('name must be specified if block is given')
    elsif !name.nil? && !name.is_a?(String)
      raise ArgumentError.new("name must be String but got #{name.inspect}")
    elsif !script.nil? && !script.is_a?(String)
      raise ArgumentError.new("script must be String but got #{script.inspect}")
    end

    @jobs << Benchmark::Driver::Configuration::Job.new(name || script, script || block)
  end

  def compare!
    @output_options[:compare] = true
  end
end
