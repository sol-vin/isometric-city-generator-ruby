require_relative '../isometric_factory.rb'

class CityFactory < PerlinFactory

  attr_reader :buildable_types

  #used to reduce the seed
  DIMINISH = 0.1**19

  BUILDING_SEED = :building.hash * DIMINISH
  BUILDING_COLOR_SEED = :building_color.hash * DIMINISH
  BUILDING_CHANCE = 6
  BUILDING_HEIGHT_SEED = :building_height_seed.hash * DIMINISH


  ROAD_SEED = :road.hash * DIMINISH
  ROAD_CHANCE = 25

  FOLIAGE_CHANCE = 4
  FOLIAGE_SEED = :foliage.hash * DIMINISH

  ROOF_CHANCE = 5
  ROOF_1_FLIP_SEED = :roof_1_flip.hash * DIMINISH
  ROOF_SEED = :roof.hash * DIMINISH

  DOOR_SEED = :door.hash * DIMINISH
  DOOR_CHANCE = 2

  BILLBOARD_CHANCE = 10
  BILLBOARD_SEED = :billboard.hash * DIMINISH
  BILLBOARD_FLIP_SEED = :billboard_flip.hash * DIMINISH

  SMALL_HOUSE_SEED = :small_house_seed.hash * DIMINISH
  SMALL_HOUSE_CHANCE = 3

  DECORATIONS_SEED = :decorations.hash


  WATER_LEVEL = 0.25
  SAND_LEVEL = 0.31
  GRASS_LEVEL = 0.53

  MAX_BUILDING_HEIGHT = 7

  def initialize(seed, size_x, size_y, size_z)
    super(seed, size_x, size_y, size_z)

    @building_colors = [0xFF_6A5039, 0xFF_F4E4CA, 0xFF_FFFDF2,
                        0xFF_E0E2DB, 0xFF_D2D4C8, 0xFF_B8BDB5,
                        0xFF_889696, 0xFF_F2C5A6, 0xFF_E49880,
                        0xFF_C37E61, 0xFF_D2D4C8, 0xFF_9D705D,
                        ]


    @buildable_types = [:tile, :block, :grass, :cement]

    @assets.add_content("city_factory")
    #@perlin_height_diminish = 0.8
  end

  def is_type_buildable?(type)
    not type.nil? and @buildable_types.include? type
  end

  def is_tile_buildable?(x, y)
    is_type_buildable?(get_tile_type(x, y))
  end

  def roll_road_x(x, y)
    get_perlin_bool_2d(x, ROAD_SEED, 1 + (get_perlin_noise(x, y)**2 * 10.0), ROAD_CHANCE)
  end

  def roll_road_y(x,y)
    get_perlin_bool_2d(ROAD_SEED, y, 1 + (get_perlin_noise(x, y)**2 * 10.0), ROAD_CHANCE)
  end

  def get_road_direction(x, y)
    return :x if roll_road_x(x, y)
    return :y if roll_road_y(x, y)
  end

  def is_a_road?(x, y)
   get_tile_ground(x, y) != :water and (roll_road_x(x, y) or roll_road_y(x, y))
  end

  def is_an_intersection?(x, y)
    get_tile_ground(x, y) != :water and roll_road_x(x, y) and roll_road_y(x, y)
  end

  def get_tile_type(x, y)


    #find out what kind of ground the tile has
    ground = get_tile_ground(x, y)
    #see if it is a road first
    # unless road_type.nil?
    #   if road_type == :road_straight
    #     case ground
    #       when :water
    #         return :bridge_straight
    #       when :grass
    #         return :small_road_straight
    #     end
    #   elsif road_type == :road_4_way
    #     case ground
    #       when :water
    #         return :bridge_straight
    #       when :grass
    #         return :small_road_straight
    #     end
    #   else
    #     return road_type
    #   end
    # end
    #find which axis
    if is_an_intersection?(x, y)
      road_type = :road_4_way
    elsif is_a_road?(x, y)
      road_type = :road_straight
    end
    return road_type unless road_type.nil?
    ground
  end

  #gets what type the tiles ground is built upon
  def get_tile_ground(x, y)
    height = get_perlin_noise(x, y)
    if height < WATER_LEVEL
      return :water
    elsif height < SAND_LEVEL
      return :sand
    elsif height < GRASS_LEVEL
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
        #flip based on view direction
        (roll_road_y(x, y) && (view == :south_west || view == :north_east)) ||
            (roll_road_x(x, y) && (view == :south_east || view == :north_west))
      else
        return false
    end
  end

  def get_block_type(x, y, z)
    type = super(x, y, z)
    return cache[x][y][z] if cache[x][y][z].eql? :uncached

    if is_building_at?(x, y)
      block_above = is_block_at?(x, y, z + 1)
      block_below_buildable = (z == 0 or is_block_buildable?(x, y, z - 1))

      if z != 0 and not block_above and block_below_buildable
        type = get_perlin_item_3d(x ,y , ROOF_SEED, @assets.f_c(:roofs))
      end
      #type = :block if block_below_buildable and block_above
    elsif type == :block or type.nil?#nonbuildable blocks
      if is_foliage_at?(x, y, z)
        type = get_perlin_item_3d(x, y, FOLIAGE_SEED, @assets.f_c(:foliage))
      elsif is_small_house_at?(x, y, z)
        type = :small_house_1
      end
    end
    #no type returned default
    return type unless type.eql? :uncached
    nil
  end

  def is_block_buildable?(x, y, z)
    is_tile_buildable?(x, y) and                        #Is our tile buildable
        is_type_buildable?(get_block_type(x, y, z)) and #are we buildable?
        (z == 0 or is_block_buildable?(x, y, z - 1))    #is our supporting block buildable? (if we have one) (recursive)
  end

  def is_block_at?(x, y, z)
    super(x, y, z) and z <= get_stack_height(x, y) and
        is_building_at?(x, y) or is_foliage_at?(x, y, z) or is_small_house_at?(x, y, z)
  end

  def get_billboard_flip(x, y)
    get_perlin_item_3d(x, y, BILLBOARD_FLIP_SEED, IsometricFactory::ROTATIONS)
  end

  def get_block_rotation(x, y, z)
    type = get_block_type(x, y, z)
    if @assets.f_c(:billboards).include?(type)
      return get_billboard_flip(x, y)
    else
      return super(x, y, z)
    end
  end

  def is_foliage_at?(x, y, z)
    z == 0 and
        !is_building_at?(x, y) and
        get_tile_type(x, y) == :grass and
        get_perlin_bool_3d(x, y, FOLIAGE_SEED, 1, FOLIAGE_CHANCE)
  end

  def is_small_house_at?(x, y, z)
    z == 0 and
        !is_building_at?(x, y) and
        get_tile_type(x, y) == :grass and
        get_perlin_bool_3d(x, y, SMALL_HOUSE_SEED, 1, SMALL_HOUSE_CHANCE)
  end

  def get_building_height_variance(x, y)
    get_perlin_int_3d(x, y, BUILDING_HEIGHT_SEED, 0, 1 + (get_perlin_noise(x, y) * 5).round)
  end

  def get_stack_height(x, y)
    ((get_perlin_noise(x, y)**2) * MAX_BUILDING_HEIGHT).to_i + (get_perlin_noise(x, y) > GRASS_LEVEL ? get_building_height_variance(x, y) : 0)
  end

  def is_building_at?(x, y)
    #V--- The first block is buildable?
    is_tile_buildable?(x, y) and #V--- Roll the dice
        get_perlin_bool_3d(x, y, BUILDING_SEED, 0.7 + (get_perlin_noise(x, y) * 3.0), BUILDING_CHANCE)
  end

  def get_block_color(x, y, z)
    if get_block_type(x,y,z) == :block or
        get_block_type(x, y, z) == :small_house_1 or
        assets.f_c(:roofs).include?(get_block_type(x,y,z))
      return get_perlin_item_3d(x, y, BUILDING_COLOR_SEED, @building_colors)
    end

    0xffffffff
  end

  def get_debug_block_color(x, y, z)
    super(0, 0, get_stack_height(x, y))
  end

  #Draw blocks override
  def draw_blocks
    case view
      when :south_east
        size_y.times do |y|
          size_x.times do |x|
            size_z.times do |z|
              break unless is_block_at?(x, y, z)
              draw_block(x, y, z, x, y, z)
            end
          end
        end
      when :south_west
        size_x.times do |y|
          size_y.times do |x|
            size_z.times do |z|
              break unless is_block_at?(size_x - 1 - y, x, z)
              draw_block(x, y, z, size_x - 1 - y, x, z)
            end
          end
        end
      when :north_west
        size_y.times do |y|
          size_x.times do |x|
            size_z.times do |z|
              break unless is_block_at?(size_x - 1 - x, size_y - 1 - y, z)
              draw_block(x, y, z, size_x - 1 - x, size_y - 1 - y, z)
            end
          end
        end
      when :north_east
        size_x.times do |y|
          size_y.times do |x|
            size_z.times do |z|
              break unless is_block_at?(y, size_y - 1 - x, z)
              draw_block(x, y, z, y, size_y - 1 - x, z)
            end
          end
        end
      #end case
    end
  end

  def get_decoration(x, y)
    get_perlin_item_3d(x, y, DECORATIONS_SEED, @assets.f_c(:windows))
  end

  def get_decorations(x, y, z)
    decorations = {}
    [:north, :south, :east, :west].each do |d|
      decorations[d] = get_decoration(x, y)
    end
    decorations
  end
end
