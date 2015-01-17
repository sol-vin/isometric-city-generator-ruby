require 'gosu'
require 'perlin_noise'

include Gosu

class IsometricFactory
  PERLIN_NOISE_STEP = 0.01
  PERLIN_NOISE = Perlin::Noise.new 2

  def get_tile_position(x, y)
    spacing = Point.new((Assets.tile_width/2.0).round, (Assets.tile_height/2.0).round)
    offset = Point.new(400, 10)

    Point.new((-x * spacing.x) + (y * spacing.x) - y + x + offset.x,
              (x * spacing.y) + (y*spacing.y) - y - x + offset.y)
  end

  def get_tile_type(x, y)

  end

  def get_building_type(x, y)

  end

  def get_building_height(x, y)

  end

  def get_block_position(x, y, z)

  end
end