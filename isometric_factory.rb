require 'perlin'
require './assets.rb'

class IsometricFactory

  OFFSET = Vector2.new(0, 0)
  MAX_HEIGHT = 6

  #Hash of direction keys, which way the camera is facing and what direction is facing clockwise
  VIEWS = {north: :west, east: :north, south: :east, west: :south}

  #Size of the landscape
  attr_reader :size_x, :size_y
  #current camera direction
  attr_reader :view

  #gets the actual position of a tile based on its index
  def self.get_tile_position(x, y)
    spacing = Vector2.new((Assets.tile_width/2.0).round, (Assets.tile_height/2.0).round)
    Vector2.new((-x * spacing.x) + (y * spacing.x) - y + x + OFFSET.x,
              (x * spacing.y) + (y*spacing.y) - y - x + OFFSET.y)
  end
  
  #gets the actual position of a block based on its index
  def self.get_block_position(x, y, z)
    position = get_tile_position(x,y)
    position.y -= (Assets.block_height / 2.0).round * (z + 1)
    position
  end

  def initialize(size_x, size_y)
    @size_x = size_x
    @size_y = size_y
    @view = :south
  end

  #finds out what kind of tile is at an index
  def get_tile_type(x, y)
    :tile
  end

  #get the color of a tile at index
  def get_tile_color(x, y)
    0xffffffff
  end

  #finds out what kind of block is at an index
  def get_block_type(x, y, z)
    (is_block_at?(x, y ,z) ? :block : nil)
  end

  #get the color of a block at an index
  def get_block_color(x, y, z)
    0xffffffff
  end
  
  #is there a block at index?
  def is_block_at?(x, y, z)
    true
  end

  def draw_tile(x_pos, y_pos, x, y)
    position = self.class.get_tile_position(x_pos, y_pos)
    Assets.get_tile_image(get_tile_type(x, y)).draw(position.x, position.y, 1, 1, 1, get_tile_color(x, y))
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
            draw_tile(x, y, size_x - y, x)
          end
        end
      when :north
        size_y.times do |y|
          size_x.times do |x|
            draw_tile(x, y, size_x - x, size_y - y)
          end
        end
      when :east
        size_x.times do |y|
          size_y.times do |x|
            draw_tile(x, y, y, size_y - x)
          end
        end
    end

  end

  #draw a single block
  #x_pos, y_pos, z_pos drawn position of the block
  #x, y, z, index of the block we want to draw at x_pos, y_pos, z_pos
  def draw_block(x_pos, y_pos, z_pos, x, y, z)
    return if get_block_type(x, y, z).nil?
    position = IsometricFactory.get_block_position(x_pos, y_pos, z_pos)
    Assets.get_block_asset(get_block_type(x, y, z)).draw(position, 1, get_block_color(x, y, z))
  end

  #draw all the blocks
  def draw_blocks
    case view
      when :south
        size_y.times do |y|
          size_x.times do |x|
            MAX_HEIGHT.times do |z|
              draw_block(x, y, z, x, y, z)
            end
          end
        end
      when :west
        size_x.times do |y|
          size_y.times do |x|
            MAX_HEIGHT.times do |z|
              draw_block(x, y, z, size_x - y, x, z)
            end
          end
        end
      when :north
        size_y.times do |y|
          size_x.times do |x|
            MAX_HEIGHT.times do |z|
              draw_block(x, y, z, size_x - x, size_y - y, z)
            end
          end
        end
      when :east
        size_x.times do |y|
          size_y.times do |x|
            MAX_HEIGHT.times do |z|
              draw_block(x, y, z, y, size_y - x, z)
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
