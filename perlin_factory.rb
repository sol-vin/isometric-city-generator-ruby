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

  #overridden methods
  def is_block_at?(x, y, z)
    (get_perlin_noise(x, y) * MAX_HEIGHT).round >= z
  end
 
  def get_block_color(x, y, z)
    color_index = ((z / MAX_HEIGHT.to_f).clamp(0, 1.0)*@perlin_colors.length).to_i
    @perlin_colors[color_index]
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

  def draw_blocks
    ranges = get_view_ranges
    if view == :south_west || view == :north_east
      ranges[:x].each_with_index do |x, x_pos|
        ranges[:y].each_with_index do |y, y_pos|
          height = get_perlin_height(x, y)
          height.times do |z|
            #skip drawing this block if we can't see it anyways.
            next if get_block_type(x, y, z).nil?
            draw_block(x_pos, y_pos, z, x, y, z)
          end
        end
      end
    end
    if view == :north_west || view == :south_east
      ranges[:y].each_with_index do |y, y_pos|
        ranges[:x].each_with_index do |x, x_pos|
          height = get_perlin_height(x, y)
          height.times do |z|
            #skip drawing this block if we can't see it anyways.
            next if get_block_type(x, y, z).nil?
            draw_block(x_pos, y_pos, z, x, y, z)
          end
        end
      end
    end
  end
end
