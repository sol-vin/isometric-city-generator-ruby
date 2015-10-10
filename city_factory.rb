require './isometric_factory.rb'

class CityFactory < PerlinFactory

  BUILDING_CHANCE = 5

  def initialize(seed, size_x, size_y)
    super(seed, size_x, size_y)

    @building_colors = []
  end



  def is_building_at?(x, y)
    get_perlin_value(x, y, 0, BUILDING_CHANCE) == 0
  end

  def is_tile_buildable?(x, y)
    Assets.is_type_buildable?(get_tile_type(x, y))
  end

  def is_block_buildable?(x, y, z)
    no_block_above = !is_block_at?(x, y, z + 1)
    block_below = is_block_at?(x, y, z - 1)
    block_below_buildable = Assets.is_type_buildable?(get_block_type(x, y, z - 1))
    (no_block_above && ((block_below && block_below_buildable) || is_tile_buildable?(x, y)) )
  end

  def is_block_at?(x, y, z)
    super(x, y, z) && is_building_at?(x, y)
  end
end
