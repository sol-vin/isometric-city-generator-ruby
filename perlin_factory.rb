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

    @perlin_colors = []
    @perlin_colors << 0xffffcc97
    @perlin_colors << 0xffffa179
    @perlin_colors << 0xffd34b59
    @perlin_colors << 0xffc13759
    @perlin_colors << 0xff744268
  end

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

  def get_perlin_value(x, y)
    "0.#{get_perlin_noise(x,y).to_s[-2..-1]}".to_f * PERLIN_VALUE_MULTIPLIER
  end

  def get_perlin_value_3d(x, y, z)
    "0.#{get_perlin_noise_3d(x, y, z).to_s[-2..-1]}".to_f * PERLIN_VALUE_MULTIPLIER
  end

  def is_block_at?(x, y, z)
    (get_perlin_noise(x, y) * MAX_HEIGHT).round >= z
  end

  def draw_blocks
    ranges = get_view_ranges
    ranges[:x].each_with_index do |x, x_pos|
      ranges[:y].each_with_index do |y, y_pos|
        height = get_perlin_height(x, y)
        height.times do |z|
          #skip drawing this block if we can't see it anyways.
          next if get_block_type(x, y, z).nil?
          color_index = ((z / MAX_HEIGHT.to_f).clamp(0, 1.0)*@perlin_colors.length).to_i
          draw_block(x_pos, y_pos, x, y, z,@perlin_colors[color_index])
        end
      end
    end
  end
end