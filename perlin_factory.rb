require './isometric_factory.rb'

class PerlinFactory < IsometricFactory
  def initialize(seed, size_x, size_y)
    super(seed, size_x, size_y)
    @perlin_colors = []
    @perlin_colors << 0xffffcc97
    @perlin_colors << 0xffffa179
    @perlin_colors << 0xffd34b59
    @perlin_colors << 0xffc13759
    @perlin_colors << 0xff744268
  end

  def draw_blocks
    size_x.times do |x|
      size_y.times do |y|
        height = (get_perlin_noise(x, y) * MAX_HEIGHT).round
        height.times do |z|
          #skip drawing this block if we can't see it anyways.
          next if is_block_at?(x + 1, y + 1, z + 1) && x == size_x && y != size_y
          next if get_block_type(x, y, z).nil?
          color_index = ((z / MAX_HEIGHT.to_f).clamp(0, 1.0)*@perlin_colors.length).to_i
          draw_block(x,y,z,@perlin_colors[color_index])
        end
      end
    end
  end
end