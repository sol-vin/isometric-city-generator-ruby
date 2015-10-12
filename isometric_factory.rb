
require './isometric_assets.rb'
require './monkey_patch.rb'

class IsometricFactory

  OFFSET = Vector2.new(0, 0)

  #Hash of direction keys, which way the camera is facing and what direction is facing clockwise
  VIEWS = {north: :west, east: :north, south: :east, west: :south}

  #Size of the landscape
  attr_reader :size_x, :size_y, :size_z, :assets
  #current camera direction
  attr_accessor :view, :debug

  #gets the actual position of a tile based on its index
  def get_tile_position(x, y)
    spacing = Vector2.new((assets.tile_width/2.0).round, (assets.tile_height/2.0).round)
    Vector2.new((-x * spacing.x) + (y * spacing.x) - y + x + OFFSET.x,
              (x * spacing.y) + (y*spacing.y) - y - x + OFFSET.y)
  end
  
  #gets the actual position of a block based on its index
  def get_block_position(x, y, z)
    position = get_tile_position(x,y)
    position.y -= (assets.block_height / 2.0).round * (z + 1)
    position
  end

  def initialize(size_x, size_y, size_z)
    @size_x = size_x
    @size_y = size_y
    @size_z = size_z
    @view = :south
    @debug = false
    @assets = IsometricAssets.new("isometric_factory")
  end

  #finds out what kind of tile is at an index
  def get_tile_type(x, y)
    :tile
  end

  #get the color of a tile at index
  def get_tile_color(x, y)
    0xffffffff
  end

  def get_debug_tile_color(x, y)
    r = (255 * (x.to_f/size_x)).to_i
    b = (255 * (y.to_f/size_y)).to_i
    g = 0

    Gosu::Color.new(r,g,b)
  end


  def is_tile_flipped_h?(x, y)
    false
  end

  def is_tile_flipped_v?(x, y)
    false
  end

  def draw_tile(x_pos, y_pos, x, y)
    position = get_tile_position(x_pos, y_pos)
    assets.get_asset(get_tile_type(x, y)).draw(position,
                                               ((debug ? get_debug_tile_color(x, y) : get_tile_color(x, y))),
                                               is_tile_flipped_h?(x, y),
                                               is_tile_flipped_v?(x, y))
  end

  #draw phase for the grid
  def draw_grid
    case view
      when :south
        size_y.times do |y|
          size_x.times do |x|
            draw_tile(x, y, x, y)
          end
        end
      when :west
        size_x.times do |y|
          size_y.times do |x|
            draw_tile(x, y, size_x - 1 - y, x)
          end
        end
      when :north
        size_y.times do |y|
          size_x.times do |x|
            draw_tile(x, y, size_x - 1 - x, size_y - 1- y)
          end
        end
      when :east
        size_x.times do |y|
          size_y.times do |x|
            draw_tile(x, y, y, size_y - 1 - x)
          end
        end
      else
        throw Exception.new("view was out of bounds!")
    end

  end


  #finds out what kind of block is at an index
  def get_block_type(x, y, z)
    (is_block_at?(x, y ,z) ? :block : nil)
  end

  #get the color of a block at an index
  def get_block_color(x, y, z)
    0xffffffff
  end

  def get_debug_block_color(x, y, z)
    r = (255 * (x.to_f/size_x)).to_i
    b = (255 * (y.to_f/size_y)).to_i
    g = (255 * (z.to_f/size_z)).to_i

    Gosu::Color.new(r,g,b)
  end


  #is there a block at index?
  def is_block_at?(x, y, z)
   !(x < 0 || y < 0 || z < 0 || x >= size_x || y >= size_y || z >= size_z)
  end

  def is_block_flipped_h?(x, y, z)
    false
  end

  #draw a single block
  #x_pos, y_pos, z_pos drawn position of the block
  #x, y, z, index of the block we want to draw at x_pos, y_pos, z_pos
  def draw_block(x_pos, y_pos, z_pos, x, y, z)
    return if get_block_type(x, y, z).nil?
    position = get_block_position(x_pos, y_pos, z_pos)
    assets.get_asset(get_block_type(x, y, z)).draw(
        position,
        ((debug ? get_debug_block_color(x, y, z) : get_block_color(x, y, z))),
        is_block_flipped_h?(x, y, z),
        false
    )
  end

  #draw all the blocks
  def draw_blocks
    case view
      when :south
        size_y.times do |y|
          size_x.times do |x|
            size_z.times do |z|
              draw_block(x, y, z, x, y, z)
            end
          end
        end
      when :west
        size_x.times do |y|
          size_y.times do |x|
            size_z.times do |z|
              draw_block(x, y, z, size_x - 1 - y, x, z)
            end
          end
        end
      when :north
        size_y.times do |y|
          size_x.times do |x|
            size_z.times do |z|
              draw_block(x, y, z, size_x - 1 - x, size_y - 1 - y, z)
            end
          end
        end
      when :east
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
