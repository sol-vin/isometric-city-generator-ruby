require 'ostruct'
require 'gosu'
#Used to hold block images and shading/lighting as well as an add-on feature
class IsometricAsset < Hash

  VIEWS = [:north_west, :north_east, :south_west, :south_east]

  attr_reader :config

  def initialize args
    @config = args

    @config[:collections].map!(&:to_sym)

    #views must contain all the rendering instructions for the renderer
    unless VIEWS.all? {|v| config[:views].keys.include?(v)}
      throw Exception.new "views keys did not contain VIEWS"
    end


  end

  def load_asset(key, location)
    self[key] = Gosu::Image.new location
  end

  def width
    self[:base].width
  end

  def height
    self[:base].height
  end

  def draw_content x, y, flip_h, flip_v, color, view
    puts "draw_content @ #{x} #{y}  #{flip_h} #{flip_v} #{color} #{view}"
    config[:views][view][:content].each do |k, v|
      real_color = ((v[:color].nil?) ? color : v[:color])
      scale_h = (flip_h ^ v[:flip_h] ? -1.0 : 1.0)
      scale_v = (flip_v ^ v[:flip_v] ? -1.0 : 1.0)
      pcx = (flip_h ? width : 0)
      pcy = (flip_v ? height : 0)

      puts "  draw_content #{k} #{real_color.to_s}"
      self[k].draw(x + pcx, y + pcy, 1, scale_h, scale_v, real_color)
    end
  end

  def draw_lighting x, y, flip_h, flip_v, color, view
    puts "draw_content @ #{x} #{y}  #{flip_h} #{flip_v} #{color.to_s} #{view}"
    config[:views][view][:lighting].each do |k, v|
      real_color = ((v[:color].nil?) ? color : v[:color])
      scale_h = (flip_h ^ v[:flip_h] ? -1.0 : 1.0)
      scale_v = (flip_v ^ v[:flip_v] ? -1.0 : 1.0)
      pcx = (flip_h ^ v[:flip_h] ? width : 0)
      pcy = (flip_v ^ v[:flip_v] ? height : 0)

      puts "  draw_content #{k} #{real_color.to_s}"
      self[k].draw(x + pcx, y + pcy, 1, scale_h, scale_v, real_color)
    end
  end
end