require_relative '../isometric_factory.rb'

class EdgeTestFactory < IsometricFactory
  attr_accessor :seed
  def initialize(seed, s_x, s_y, s_z)
    @seed = seed
    super(s_x, s_y, s_z)
  end

  def is_block_at?(x, y, z)
    edge = 0
    edge += 1 if x == 0 or x == size_x-1
    edge += 1 if y == 0 or y == size_y-1
    edge += 1 if z == 0 or z == size_z-1
    edge >= 2 and super(x, y, z)
  end
end