require "matrix"
require "./reactor"
require "./flasher"

def optimize(x1, x4, x6, old_x7)
  x2 = (Vector[*x1] + Vector[*x4] + Vector[*x6]).to_a
  reactor = Reactor.new(x2, 200.0)
  x3 = reactor.outlet
  high_flasher = Flasher.new(reactor.outlet, 133.0)
  high_flasher.optimize_by_recovery_ratios([0.0, 0.8228, 0.0])
  x4 = high_flasher.vapor
  x5 = high_flasher.liquid
  low_flasher = Flasher.new(x5, 82.3)
  low_flasher.optimize_by_recovery_ratios([0.0, 0.9737, 0.0])
  x6 = low_flasher.vapor
  x7 = low_flasher.liquid
  if (x7[E_NH3]-old_x7[E_NH3]).abs < ACCURACY
    {
      pipes: [x1, x2, x3, x4, x5, x6, x7],
      reactor: reactor,
      high_flasher: high_flasher,
      low_flasher: low_flasher
    }
  else
    optimize(x1, x4, x6, x7)
  end
end

nh3 = 2.051
co2 = 1.002
x1 = [nh3-co2*2, co2, 0.0, 0.0]
x4 = [0.0, 0.0, 0.0, 0.0]
x6 = [0.0, 0.0, 0.0, 0.0]
x7 = [0.0, 0.0, 0.0, 0.0]
result = optimize(x1, x4, x6, x7)
result[:pipes].each.with_index(1) do |pipe, index|
  puts "x#{index}: #{pipe.map{|i| i.round(3)}}"
end
cv = result[:pipes][6][UREA]/result[:pipes][0][CARBAMATE]
puts "cv: #{cv.round(3)}"
p_high = result[:high_flasher].total_pressure
p_low = result[:low_flasher].total_pressure
puts "P_high: #{p_high.round(3)} atm"
puts "P_low: #{p_low.round(3)} atm"
