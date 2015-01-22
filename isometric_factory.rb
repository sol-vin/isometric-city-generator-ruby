require 'perlin'
require './assets.rb'

class IsometricFactory
  PERLIN_STEP = 0.02
  PERLIN_OCTAVE = 8
  PERLIN_PERSIST = 0
  PERLIN_VALUE_MULTIPLIER = 9
  OFFSET = Point.new(0, 0)
  MAX_HEIGHT = 6



  attr_reader :perlin_noise
  attr_reader :size_x, :size_y
  attr_reader :seed

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

  def initialize(seed, size_x, size_y)
    @size_x = size_x
    @size_y = size_y
    @seed = seed

    @perlin_noise = Perlin::Generator.new(seed, PERLIN_PERSIST, PERLIN_OCTAVE)
  end

  def get_tile_type(x, y)
    :tile
  end

  def get_block_type(x, y, z)
    (is_block_at?(x, y ,z) ? :block : nil)
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

  def get_perlin_noise(x, y)
    (@perlin_noise[x * PERLIN_STEP, y * PERLIN_STEP] + 1) / 2.0
  end

  def get_perlin_value(x, y)
    "0.#{get_perlin_noise(x,y).to_s[-2..-1]}".to_f * PERLIN_VALUE_MULTIPLIER
  end

  #Finds if there is a block at the specified location
  def is_block_at?(x, y, z)
    (get_perlin_noise(x, y) * MAX_HEIGHT).round >= z
  end


  def draw_grid
    size_x.times do |x|
      size_y.times do |y|
        position = self.class.get_tile_position(x, y)
        Assets.get_tile_image(get_tile_type(x, y)).draw(position.x, position.y, 1, 1, 1, 0xffffffff)
      end
    end
  end

  def draw_block(x, y, z, color)
    position = IsometricFactory.get_block_position(x, y, z)
    Assets.get_block_asset(get_block_type(x, y, z)).draw(position, 1, color)
  end

  def draw_blocks

  end
end