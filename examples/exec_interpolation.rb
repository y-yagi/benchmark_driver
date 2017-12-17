require 'benchmark/driver'

Benchmark.driver do |x|
  x.prelude = <<-EOS
    large_a = "Hellooooooooooooooooooooooooooooooooooooooooooooooooooo"
    large_b = "Wooooooooooooooooooooooooooooooooooooooooooooooooooorld"

    small_a = "Hello"
    small_b = "World"
  EOS

  x.report('large', script: '"#{large_a}, #{large_b}!"')
  x.report('small', script: '"#{small_a}, #{small_b}!"')
  x.compare!
end
