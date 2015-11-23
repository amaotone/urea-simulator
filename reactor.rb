require "./const"

class Reactor
  def initialize(inlet, temperature)
    @e_ammonia, @carbamate, @water, @urea = inlet
    @temp = temperature
  end

  def outlet
    e_ammonia = @e_ammonia
    carbamate = @carbamate*(1-cv)
    water = @carbamate*cv + @water
    urea = @carbamate*cv

    [e_ammonia, carbamate, water, urea]
  end

  private

  def cv
    a = (@carbamate*2 + @e_ammonia)/@carbamate
    b = @water/@carbamate

    cv = 0.2616*a - 0.0194*a**2 +0.0382*a*b - 0.1160*b - (0.02732*a + 0.1030*b-1.640)*(@temp/100) - 0.1394*(@temp/100)**3 - 1.869
  end
end
