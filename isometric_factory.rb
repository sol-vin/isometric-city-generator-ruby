require 'perlin_noise'

class IsometricFactory
  PERLIN_NOISE_STEP = 0.01

  attr_reader :perlin_noise, :offset
  attr_reader :size_x, :size_y

  def initialize size_x, size_y
    @size_x = size_x
    @size_y = size_y
    @perlin_noise = Perlin::Noise.new 2
    @offset = Point.new(400, 10)
    @spacing = Point.new((Assets.tile_width/2.0).round, (Assets.tile_height/2.0).round)
  end

  def self.get_tile_position(x, y)
    Point.new((-x * @spacing.x) + (y * @spacing.x) - y + x + @offset.x,
              (x * @spacing.y) + (y*@spacing.y) - y - x + @offset.y)
  end

  def get_tile_type(x, y)

  end

  def get_building_type(x, y)

  end

  def get_building_height(x, y)

  end

  def self.get_block_position(x, y, z)

  end

  def draw_grid
    size_x.times do |x|
      size_y.times do |y|
        position = self.class.get_tile_position(x,y)
        Assets.get_tile_image(:base_tile).draw(position.x, position.y, 1)
      end
    end
  end

  def draw_blocks

  end
end