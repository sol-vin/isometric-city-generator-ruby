require './isometric_factory.rb'

class CityFactory < PerlinFactory

  BUILDING_CHANCE = 5

  def initialize(seed, size_x, size_y)
    super(seed, size_x, size_y)
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

  def draw_grid
    size_x.times do |x|
      size_y.times do |y|
        position = self.class.get_tile_position(x, y)
        Assets.get_tile_image(get_tile_type(x, y)).draw(position.x, position.y, 1, 1, 1, 0xffffcc97)
      end
    end
  end

  def draw_blocks
    ranges = get_view_ranges
    if view == :north_west || view == :south_east
      ranges[:x].each_with_index do |x, x_pos|
        ranges[:y].each_with_index do |y, y_pos|
          next unless is_building_at?(x, y)
          get_perlin_height(x, y).times do |z|
            #skip drawing this block if we can't see it anyways.
            next if get_block_type(x, y, z).nil?
            draw_block(x_pos, y_pos, z, x, y, z)
          end
        end
      end
    end
    if view == :south_west || view == :north_east
      ranges[:y].each_with_index do |y, y_pos|
        ranges[:x].each_with_index do |x, x_pos|
          next unless is_building_at?(x, y)
          height = get_perlin_height(x, y)
          height.times do |z|
            #skip drawing this block if we can't see it anyways.
            next if get_block_type(x, y, z).nil?
            draw_block(x_pos, y_pos, z, x, y, z)
          end
        end
      end
    end
  end
end
