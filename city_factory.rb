require './isometric_factory.rb'

class CityFactory < PerlinFactory

  attr_reader :buildable_types

  #used to reduce the seed
  DIMINISH = 0.1**19

  BUILDING_SEED = :building.hash * DIMINISH
  BUILDING_COLOR_SEED = :building_color.hash * DIMINISH
  BUILDING_CHANCE = 5
  ROAD_SEED = :road_seed.hash * DIMINISH
  ROAD_CHANCE = 25
  FOLIAGE_CHANCE = 4
  FOLIAGE_SEED = :foliage.hash * DIMINISH
  ROOF_CHANCE = 5
  ROOF_1_FLIP_SEED = :roof_1_flip.hash * DIMINISH
  ROOF_SEED = :roof.hash * DIMINISH
  DOOR_SEED = :door.hash * DIMINISH
  DOOR_CHANCE = 2
  BILLBOARD_CHANCE = 10
  BILLBOARD_SEED = :billboard_seed.hash * DIMINISH
  BILLBOARD_FLIP_SEED = :billboard_flip_seed.hash * DIMINISH

  def initialize(seed, size_x, size_y, size_z)
    super(seed, size_x, size_y, size_z)

    @building_colors = [0xFF_6A5039, 0xFF_F4E4CA, 0xFF_FFFDF2,
                        0xFF_E0E2DB, 0xFF_D2D4C8, 0xFF_B8BDB5,
                        0xFF_889696, 0xFF_F2C5A6, 0xFF_E49880,
                        0xFF_C37E61, 0xFF_D2D4C8, 0xFF_9D705D,
                        ]

    @assets.add_content("city_factory")
    @assets.add_alias(:grass, :tile)
    @assets.add_alias(:cement, :tile)
    @assets.add_alias(:water, :tile)
    @assets.add_alias(:roof_5, :small_house_1)

    @buildable_types = [:tile, :block, :grass, :cement]
  end

  def is_type_buildable?(type)
    not type.nil? and @buildable_types.include? type
  end

  def is_tile_buildable?(x, y)
    is_type_buildable?(get_tile_type(x, y))
  end

  def roll_road_x(x)
    get_perlin_bool_2d(x, ROAD_SEED, 1, ROAD_CHANCE)
  end

  def roll_road_y(y)
    get_perlin_bool_2d(ROAD_SEED, y, 1, ROAD_CHANCE)
  end

  def get_road_direction(x, y)
    return :x if roll_road_x x
    return :y if roll_road_y y
  end

  def is_a_road?(x, y)
   roll_road_x(x) || roll_road_y(y)
  end

  def is_an_intersection?(x, y)
    roll_road_x(x) && roll_road_y(y)
  end

  def get_tile_type(x, y)
    #see if it is a road first
    if is_a_road?(x, y) || is_an_intersection?(x, y)
      #find which axis
      if is_an_intersection?(x, y)
        return :road_4_way
      else
        return :road_straight
      end
    end

    height = get_perlin_height(x, y)
    if height <= 1
      return :water
    elsif height < 4
      return :grass
    else
      return :cement
    end
  end

  def get_tile_color(x, y)
    0xffffffff
  end

  def is_tile_flipped_h?(x, y)
    type = get_tile_type(x, y)
    case(type)
      when :road_4_way
        false
      when :road_straight
        (roll_road_y(y) && (view == :south_west || view == :north_east)) ||
            (roll_road_x(x) && (view == :south_east || view == :north_west))
      else
        return false
    end
  end

  def get_block_type(x, y, z)
    return nil unless is_block_at?(x, y, z)
    unless is_block_at?(x, y, z+1)
      return get_perlin_item_3d(x, y, ROOF_SEED, @assets.f_c(:roofs))
    end
    return :block
  end

  def is_block_buildable?(x, y, z)
    is_tile_buildable?(x, y) and is_type_buildable?(get_block_type(x, y, z))
  end

  def is_block_at?(x, y, z)
    super(x, y, z) && (is_building_at?(x, y) || is_foliage_at?(x, y))
  end

  def is_foliage_at?(x, y)
    get_tile_type(x, y) == :grass && get_perlin_bool_3d(x, y, FOLIAGE_SEED, 1, FOLIAGE_CHANCE)
  end

  def is_building_at?(x, y)
    #V--- The first block is buildable?  V--- Roll the dice
    is_tile_buildable?(x, y) and get_perlin_bool_3d(x, y, BUILDING_SEED, 1, BUILDING_CHANCE)
  end

  def get_block_color(x, y, z)
    if get_block_type(x,y,z) == :block || get_block_type(x, y, z) == :small_house_1 || assets.f_c(:roofs).include?(get_block_type(x,y,z))
      return get_perlin_item_3d(x, y, BUILDING_COLOR_SEED, @building_colors)
    end

    0xffffffff
  end
end
