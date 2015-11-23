require "matrix"
require "./reactor"
require "./flasher"
# x0 = [3.0, 1.0, 0.6, 0.0]
# reactor = Reactor.new(x0, 200.0)
# p reactor.outlet
# flasher = Flasher.new(reactor.outlet, 120.0)
# flasher.optimize_by_recovery_ratios([0.0, 0.9, 0.0])
# p flasher.vapor
# p flasher.liquid
# flasher.optimize_by_total_pressure(16.12, [0.0, 1.0])
# p flasher.vapor.map{|i| i.round(3)}
# p flasher.liquid.map{|i| i.round(3)}

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
    x7
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
p optimize(x1, x4, x6, x7)
