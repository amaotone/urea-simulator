require "matrix"
require "./reactor"
require "./flasher"
x0 = [3.0, 1.0, 0.6, 0.0]
reactor = Reactor.new(x0, 200.0)
p reactor.outlet
flasher = Flasher.new(reactor.outlet, 120.0)
p flasher.optimize_by_recovery_ratios([0.1, 0.9, 0.1])
