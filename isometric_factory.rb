
require './isometric_assets.rb'
require './monkey_patch.rb'

class IsometricFactory

  OFFSET = Vector2.new(0, 0)

  #Hash of direction keys, which way the camera is facing and what direction is facing clockwise
  VIEWS = {north_west: :south_west, north_east: :north_west, south_east: :north_east, south_west: :south_east}
  ROTATIONS = [:none_, :quarter_turn, :half_turn, :three_quarter_turn]
  #Size of the landscape
  attr_reader :size_x, :size_y, :size_z, :assets
  #current camera direction
  attr_accessor :view, :debug

  def initialize(size_x, size_y, size_z)
    @size_x = size_x
    @size_y = size_y
    @size_z = size_z
    @view = :south_east
    @debug = false
    @assets = IsometricAssets.new("isometric_factory")
  end

  #gets the actual position of a tile based on its index
  def get_tile_position(x, y)
    spacing = Vector2.new((assets.tile_width/2.0).round, (assets.tile_height/2.0).round)
    Vector2.new((-x * spacing.x) + (y * spacing.x) - y + x + OFFSET.x,
                (x * spacing.y) + (y*spacing.y) - y - x + OFFSET.y)
  end

  def get_tile_rotation(x, y)
    #TODO: Add rotation for all 16 cardinal directions
  end

  #finds out what kind of tile is at an index
  def get_tile_type(x, y)
    :tile
  end

  #get the color of a tile at index
  def get_tile_color(x, y)
    0xffffffff
  end

  #gets the color of the tile when debug mode is active
  def get_debug_tile_color(x, y)
    r = (255 * (x.to_f/size_x)).to_i
    b = (255 * (y.to_f/size_y)).to_i
    g = 0

    Gosu::Color.new(r,g,b)
  end

  def is_tile_at?(x, y)
    not (x < 0 or y < 0 or x > size_x or y > size_y)
  end

  #is the tile flipped horizontally?
  def is_tile_flipped_h?(x, y)
    false
  end

  #is the tile flipped vertically?
  def is_tile_flipped_v?(x, y)
    false
  end


  #draws the tile at a position
  def draw_tile(x_pos, y_pos, x, y)
    return unless is_tile_at?(x, y)
    position = get_tile_position(x_pos, y_pos)

    tile_image = assets.get_asset(get_tile_type(x, y))



    tile_image.draw_layer(:content,
                          position.x,
                          position.y,
                          is_tile_flipped_h?(x, y),
                          is_tile_flipped_v?(x, y),
                          ((debug ? get_debug_tile_color(x, y) : get_tile_color(x, y))),
                          view,
                          debug)
  end

  #draw phase for the grid
  def draw_grid
    case view
      when :south_east
        size_y.times do |y|
          size_x.times do |x|
            draw_tile(x, y, x, y)
          end
        end
      when :south_west
        size_x.times do |y|
          size_y.times do |x|
            draw_tile(x, y, size_x - 1 - y, x)
          end
        end
      when :north_west
        size_y.times do |y|
          size_x.times do |x|
            draw_tile(x, y, size_x - 1 - x, size_y - 1- y)
          end
        end
      when :north_east
        size_x.times do |y|
          size_y.times do |x|
            draw_tile(x, y, y, size_y - 1 - x)
          end
        end
      else
        throw Exception.new("view was out of bounds!")
    end

  end

  #gets the actual position of a block based on its index
  def get_block_position(x, y, z)
    position = get_tile_position(x,y)
    position.y -= (assets.block_height / 2.0).round * (z + 1)
    position
  end

  #finds out what kind of block is at an index
  def get_block_type(x, y, z)
    (is_block_at?(x, y ,z) ? :block : nil)
  end

  #get the color of a block at an index
  def get_block_color(x, y, z)
    0xffeeeeee
  end

  def get_block_rotation(x, y, z)

  end

  #gets the color of the block when debug mode is active
  def get_debug_block_color(x, y, z)
    r = (255 * (x.to_f/size_x)).to_i
    b = (255 * (y.to_f/size_y)).to_i
    g = (255 * (z.to_f/size_z)).to_i

    Gosu::Color.new(r,g,b)
  end


  #is there a block at index?
  def is_block_at?(x, y, z)
   not (x < 0 || y < 0 || z < 0 || x >= size_x || y >= size_y || z >= size_z)
  end

  def is_block_flipped_h?(x, y, z)
    false
  end

  def is_block_flipped_v?(x, y, z)
    false
  end


  #draw a single block
  #x_pos, y_pos, z_pos drawn position of the block
  #x, y, z, index of the block we want to draw at x_pos, y_pos, z_pos
  def draw_block(x_pos, y_pos, z_pos, x, y, z)
    return if get_block_type(x, y, z).nil?
    position = get_block_position(x_pos, y_pos, z_pos)
    block_image = assets.get_asset(get_block_type(x, y, z))
    color = ((debug ? get_debug_block_color(x, y, z) : get_block_color(x, y, z)))

    block_image.draw_layer(:content,
                           position.x,
                           position.y,
                           is_block_flipped_h?(x, y, z),
                           is_block_flipped_v?(x, y, z),
                           color,
                           view,
                           debug)

    block_image.draw_layer(:lighting,
                           position.x,
                           position.y,
                           is_block_flipped_h?(x, y, z),
                           is_block_flipped_v?(x, y, z),
                           0x10ffffff,
                           view)
  end

  #draw all the blocks
  def draw_blocks
    case view
      when :south_east
        size_y.times do |y|
          size_x.times do |x|
            size_z.times do |z|
              draw_block(x, y, z, x, y, z)
            end
          end
        end
      when :south_west
        size_x.times do |y|
          size_y.times do |x|
            size_z.times do |z|
              draw_block(x, y, z, size_x - 1 - y, x, z)
            end
          end
        end
      when :north_west
        size_y.times do |y|
          size_x.times do |x|
            size_z.times do |z|
              draw_block(x, y, z, size_x - 1 - x, size_y - 1 - y, z)
            end
          end
        end
      when :north_east
        size_x.times do |y|
          size_y.times do |x|
            size_z.times do |z|
              draw_block(x, y, z, y, size_y - 1 - x, z)
            end
          end
        end
    end
  end
  #rotate the view counter clockwise
  def rotate_counter_clockwise
    @view = VIEWS[view]
  end

  #rotate the view clockwise
  def rotate_clockwise
    @view = VIEWS.invert[view]
  end

  #dumps all the blocks in a specific region to a stream
  def dump_blocks(stream, x_start, y_start, z_start, x_end, y_end, z_end)

  end
end
