require './isometric_factory.rb'

class PerlinFactory < IsometricFactory

  PERLIN_STEP = 0.02
  PERLIN_OCTAVE = 8
  PERLIN_PERSIST = 0
  PERLIN_VALUE_MULTIPLIER = 9

  attr_reader :seed

  def initialize(seed, size_x, size_y)
    super(size_x, size_y)
    @seed  = seed
    @perlin_noise = Perlin::Generator.new(seed, PERLIN_PERSIST, PERLIN_OCTAVE)
  end

  #overridden methods
  def is_block_at?(x, y, z)
    (get_perlin_noise(x, y) * MAX_HEIGHT).round >= z
  end

  def get_tile_color(x, y)
    r = (255 * (x.to_f/size_x)).to_i
    b = (255 * (y.to_f/size_y)).to_i
    g = 0

    Gosu::Color.new(r,g,b)
  end

  def get_block_color(x, y, z)
    r = (255 * (x.to_f/size_x)).to_i
    b = (255 * (y.to_f/size_y)).to_i
    g = (255 * (z.to_f/MAX_HEIGHT)).to_i

    Gosu::Color.new(r,g,b)
  end
  #new methods

  def seed=(value)
    @seed = value
    @perlin_noise = Perlin::Generator.new(seed, PERLIN_PERSIST, PERLIN_OCTAVE)
  end

  def get_perlin_height(x, y)
    (get_perlin_noise(x, y) * MAX_HEIGHT).round
  end

  def get_perlin_noise(x, y)
    (@perlin_noise[x * PERLIN_STEP, y * PERLIN_STEP] + 1) / 2.0
  end

  def get_perlin_noise_3d(x, y, z)
    (@perlin_noise[x * PERLIN_STEP, y * PERLIN_STEP, z * PERLIN_STEP] + 1) / 2.0
  end

  def get_perlin_value(x, y, low, high)
    throw Exception.new("start must be less than end!") if low > high
    (get_perlin_noise(x,y).to_s[-6..-1].to_i % (high-low)) + low
  end

  def get_perlin_value_3d(x, y, z, low, high)
    throw Exception.new("start must be less than end!") if low > high
    (get_perlin_noise_3d(x,y,z).to_s[-6..-1].to_i % (high-low)) + low
  end
end
