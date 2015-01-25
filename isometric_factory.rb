require 'perlin'
require './assets.rb'

class IsometricFactory

  OFFSET = Point.new(0, 0)
  MAX_HEIGHT = 6

  VIEWS = {west_south: :north_west, north_west: :east_north, east_north: :south_east, south_east: :west_south}

  attr_reader :size_x, :size_y
  attr_reader :view

  def self.get_tile_position(x, y)
    spacing = Point.new((Assets.tile_width/2.0).round, (Assets.tile_height/2.0).round)
    Point.new((-x * spacing.x) + (y * spacing.x) - y + x + OFFSET.x,
              (x * spacing.y) + (y*spacing.y) - y - x + OFFSET.y)
  end

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

  def get_tile_type(x, y)
    :tile
  end

  def get_block_type(x, y, z)
    (is_block_at?(x, y ,z) ? :block : nil)
  end

  def is_block_at(x, y, z)
    true
  end

  def draw_grid
    size_x.times do |x|
      size_y.times do |y|
        position = self.class.get_tile_position(x, y)
        Assets.get_tile_image(get_tile_type(x, y)).draw(position.x, position.y, 1, 1, 1, 0xffffffff)
      end
    end
  end

  def draw_block(x_pos, y_pos, x, y, z, color)
    position = IsometricFactory.get_block_position(x_pos, y_pos, z)
    Assets.get_block_asset(get_block_type(x, y, z)).draw(position, 1, color)
  end

  def draw_blocks

  end

  def rotate_counter_clockwise
    @view = VIEWS[view]
  end

  def rotate_clockwise
    @view = VIEWS.invert[view]
  end

  def get_view_ranges
    x_ranges = {east: {start: size_x, end: 0}, west: {start: 0, end: size_x}}
    y_ranges = {north:  {start: size_y, end: 0}, south:  {start: 0, end: size_y}}
    views = view.to_s.split('_').map {|s| s.to_sym}
    ranges = {}
    ranges[:x] = x_ranges[((views.first.length == 4) ? views.first : views.last)]
    ranges[:y] = y_ranges[((views.first.length == 5) ? views.first : views.last)]
    enums = ranges.map do |key, value|
      if value[:start] > value[:end]
        enum = (value[:start] - 1).downto(value[:end]).to_a
      else
        enum = value[:start].upto(value[:end] - 1).to_a
      end
      [key, enum]
    end
    Hash[enums]
  end
end
