require_relative '../isometric_factory.rb'

class SineWaveFactory < IsometricFactory
  attr_accessor :seed
  def initialize(seed, s_x, s_y, s_z)
    @seed = seed
    super(s_x, s_y, s_z)
  end

  def is_block_at?(x, y, z)
    #x is time, y is true, z is sin height

    time = ((x*1.0)/size_x) * 24
    height = 2 + (Math.sin(time) * (size_z-2)) + 1.0

    super(x, y, z) and z <= height

  end
end