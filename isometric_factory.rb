
require './isometric_assets.rb'
require './monkey_patch.rb'

class IsometricFactory

  OFFSET = Vector2.new(0, 0)

  #Hash of direction keys, which way the camera is facing and what direction is facing clockwise
  VIEWS = {north_west: :south_west, north_east: :north_west, south_east: :north_east, south_west: :south_east}

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
    @view = :south_east
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
    flip_h = is_tile_flipped_h?(x, y)
    flip_v = is_tile_flipped_v?(x, y)


    tile_image = assets.get_asset(get_tile_type(x, y))
    scale_h = (flip_h ? -1.0 : 1.0)
    scale_v = (flip_v ? 1.0 : 1.0)
    pcx = (flip_h ? tile_image.width : 0)
    pcy = (flip_v ? tile_image.height : 0)

    tile_image.base.draw(position.x + pcx,
                         position.y + pcy,
                         1,
                         scale_h,
                         scale_v,
                         ((debug ? get_debug_tile_color(x, y) : get_tile_color(x, y))))
    #.draw(position,
     #                                          ((debug ? get_debug_tile_color(x, y) : get_tile_color(x, y))),
     #                                          is_tile_flipped_h?(x, y),
      #                                         is_tile_flipped_v?(x, y))
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
    block_image = assets.get_asset(get_block_type(x, y, z))
    flip_h = is_block_flipped_h?(x, y, z)
    scale_h = (flip_h ? -1.0 : 1.0)
    pcx = (flip_h ? block_image.width : 0)

    block_image.base.draw(position.x + pcx, position.y, 1, scale_h, 1, ((debug ? get_debug_block_color(x, y, z) : get_block_color(x, y, z))))
    block_image.feature.draw(position.x + pcx, position.y, 1, scale_h, 1, 0xffffffff) if block_image.has_feature?
    draw_decorations(x_pos, y_pos, z_pos, x, y, z)
    block_image.light.draw(position.x + pcx, position.y, 1, scale_h, 1, 0x10ffffff) if block_image.has_light?
    block_image.shade.draw(position.x + pcx, position.y, 1, scale_h, 1, 0x10ffffff) if block_image.has_shade?
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

  def get_decorations(x, y, z)
    return {}
  end

  def draw_decorations(x_pos, y_pos, z_pos, x, y, z)
    decorations = get_decorations(x, y, z)
    case view
      when :south_east
        left_dec = decorations[:east]
        right_dec = decorations[:south]
      when :south_west
        left_dec = decorations[:south]
        right_dec = decorations[:west]
      when :north_east
        left_dec = decorations[:north]
        right_dec = decorations[:east]
      when :north_west
        left_dec = decorations[:west]
        right_dec = decorations[:north]
    end

    position = get_block_position(x_pos, y_pos, z_pos)
    unless left_dec.nil?
      assets.get_asset(left_dec).base.draw(position.x, position.y, 1, 1, 1, ((debug ? get_debug_block_color(x, y, z) : 0xffffffff)))
    end
    unless right_dec.nil?
      assets.get_asset(right_dec).base.draw(position.x + assets.block_width, position.y, 1, -1.0, 1, ((debug ? get_debug_block_color(x, y, z) : 0xffffffff)))
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
