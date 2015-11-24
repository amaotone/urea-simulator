require "matrix"
require "./const"

class Flasher
  attr_accessor :vapor, :liquid

  def initialize(inlet, temperature)
    @inlet = inlet
    @temp = temperature
    @vapor = []
    @liquid = []
  end

  def optimize_by_recovery_ratios(recovery_ratios)
    @vapor = [@inlet[E_NH3]*recovery_ratios[E_NH3], @inlet[CARBAMATE]*recovery_ratios[CARBAMATE], @inlet[H2O]*recovery_ratios[H2O], 0.0]
    @liquid = (Vector[*@inlet]-Vector[*@vapor]).to_a

    # calc new recovery ratios ([eta1, eta2, eta3])
    new_recovery_ratios = []
    tmp = (gamma(E_NH3)*p0(E_NH3))/(gamma(CARBAMATE)*p0(CARBAMATE))*(recovery_ratios[CARBAMATE]/(1-recovery_ratios[CARBAMATE]))
    new_recovery_ratios[E_NH3] = tmp/(1+tmp)
    new_recovery_ratios[CARBAMATE] = recovery_ratios[CARBAMATE]
    tmp = (gamma(H2O)*p0(H2O))/(gamma(CARBAMATE)*p0(CARBAMATE))*(recovery_ratios[CARBAMATE]/(1-recovery_ratios[CARBAMATE]))
    new_recovery_ratios[H2O] = tmp/(1+tmp)

    if (new_recovery_ratios[E_NH3]-recovery_ratios[E_NH3]).abs < ACCURACY
      new_recovery_ratios
    else
      optimize_by_recovery_ratios(new_recovery_ratios)
    end
  rescue SystemStackError
    p "stack overflow!"
    return nil
  end

  def optimize_by_total_pressure(expected_total_pressure, bounds)
    min, max = bounds
    mid = (min + max)/2
    optimize_by_recovery_ratios([0.0, mid, 0.0])

    if (max-min).abs < ACCURACY
      return @vapor, @liquid
    else
      if total_pressure > expected_total_pressure
        new_bounds = [mid, max]
      else
        new_bounds = [min, mid]
      end
      optimize_by_total_pressure(expected_total_pressure, new_bounds)
    end
  end

  def total_pressure
    partial_pressure(E_NH3)+partial_pressure(CARBAMATE)+partial_pressure(H2O)
  end

  private

  def partial_pressure(i)
    gamma(i)*p0(i)*x(i)
  end

  def x(i)
    @liquid[i]/(@liquid[E_NH3]+@liquid[CARBAMATE]+@liquid[H2O])
  end

  def gamma(i)
    log_gamma =
      case i
      when E_NH3
        (-0.796*x(H2O)**2 - 2.155*x(CARBAMATE)*x(H2O)) / (x(E_NH3) + 1.22*x(CARBAMATE) + 1.038*x(H2O))**2
      when CARBAMATE
        (0.82*x(H2O)**2 + 1.237*x(E_NH3)*x(H2O)) / (0.819*x(E_NH3)+x(CARBAMATE)+0.835*x(H2O))**2
      when H2O
        (-0.755*x(E_NH3)**2 + 1.411*x(CARBAMATE)**2 - 0.236*x(E_NH3)*x(CARBAMATE)) / (0.938*x(E_NH3) + 1.198*x(CARBAMATE) + x(H2O))**2
      else nil
      end
    gamma = 10**log_gamma
  end

  def p0(i)
    case i
    when E_NH3
      10**(5.824316 - 1930.07 / (@temp + 378.6))
    when CARBAMATE
      if @temp >= 122
        10**(8.642 - 2640.0/(@temp + 230.0))*0.967841
      else
        10**(6.579 - 1914.3/(@temp + 230.0))*0.967841
      end
    when H2O
      10**(5.08599 - 1668.21/(@temp + 228.0))
    else nil
    end
  end
end
