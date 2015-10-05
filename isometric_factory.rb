require 'perlin'
require './assets.rb'

class IsometricFactory

  OFFSET = Vector2.new(0, 0)
  MAX_HEIGHT = 6

  #Hash of direction keys, which way the camera is facing and what direction is facing clockwise
  VIEWS = {south_west: :north_west, north_west: :north_east, north_east: :south_east, south_east: :south_west}

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
    @view = :north_west
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
  
  #draw phase for the grid
  def draw_grid
    size_x.times do |x|
      size_y.times do |y|
        position = self.class.get_tile_position(x, y)
        Assets.get_tile_image(get_tile_type(x, y)).draw(position.x, position.y, 1, 1, 1, 0xffffffff)
      end
    end
  end

  #draw a single block
  #x_pos, y_pos, z_pos drawn position of the block
  #x, y, z, index of the block we want to draw at x_pos, y_pos, z_pos
  def draw_block(x_pos, y_pos, z_pos, x, y, z)
    position = IsometricFactory.get_block_position(x_pos, y_pos, z_pos)
    Assets.get_block_asset(get_block_type(x, y, z)).draw(position, 1, get_block_color(x, y, z))
  end

  #draw all the blocks
  def draw_blocks
    
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
  
  #find the angle for drawing the blocks 
  def get_view_ranges
    x_ranges = {east: {start: 0, end: @size_x-1}, west: {start: @size_x-1, end: 0}}
    y_ranges = {north:  {start: @size_y-1, end: 0}, south: {start: 0, end: @size_y-1}}
    views = view.to_s.split('_').map {|s| s.to_sym}
    ranges = {}
    ranges[:x] = x_ranges[((views.first.length == 4) ? views.first : views.last)]
    ranges[:y] = y_ranges[((views.first.length == 5) ? views.first : views.last)]
    enums = ranges.map do |key, value|
      if value[:start] > value[:end]
        enum = value[:start].downto(value[:end])
      else
        enum = value[:start].upto(value[:end])
      end
      [key, enum]
    end
    Hash[enums]
  end
end
