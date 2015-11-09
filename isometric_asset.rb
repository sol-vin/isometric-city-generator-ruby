require 'ostruct'
require 'gosu'
#Used to hold block images and shading/lighting as well as an add-on feature
class IsometricAsset < Hash

  VIEWS = [:north_west, :north_east, :south_west, :south_east]

  attr_reader :config
  attr_reader :name

  def initialize name, args
    @name = name
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
    # || Access the config file (cfg) from the assets base dir.
    # ||    || contains a list of the 4 psible rotations and wha shading should be drawn for each
    # ||    ||      || get the current views rendering and layer data
    # ||    ||      ||    || get only the content layer
    # \/    \/      \/    \/
    config[:views][view][:content].each do |asset_name, asset_options|
      # the color of the object as provided the config, or at runtime,
      # config overrides the color passed into this method via arguments
      # this is to prevent specially colored objects from taking color properties
      # if you specify a color in the cfg for this asset, it will override the color
      # passed in by argument color.
      real_color = ((asset_options[:color].nil?) ? color : asset_options[:color])

      # the scale of the object
      # flip values (flip_h, flip_v) are xor'd with the flip value passed in by the config
      # TODO: Make flip decisions for non symetrical objects. that need to have bases 16 for each rotation and view
      scale_h = (flip_h ^ asset_options[:flip_h] ? -1.0 : 1.0)
      scale_v = (flip_v ^ asset_options[:flip_v] ? -1.0 : 1.0)

      # positional correction for the flip
      pcx = (flip_h ? width : 0)
      pcy = (flip_v ? height : 0)

      #Access the asset and draw it
      self[asset_name].draw(x + pcx, y + pcy, 1, scale_h, scale_v, real_color)
    end
  end

  def draw_lighting x, y, flip_h, flip_v, color, view

    #skip if there is no lighting layer
    if config[:views][view][:lighting].nil?
      #puts "ERROR! Lighting was attempted to be drawn when there was no lighting."
      return
    end

    # || Access the config file (cfg) from the assets base dir.
    # ||    || contains a list of the 4 psible rotations and wha shading should be drawn for each
    # ||    ||      || get the current views rendering and layer data
    # ||    ||      ||    || get only the lighting layer
    # \/    \/      \/    \/
    config[:views][view][:lighting].each do |asset_name, asset_options|
      # the color of the object as provided the config, or at runtime,
      # config overrides the color passed into this method via arguments
      # this is to prevent specially colored objects from taking color properties
      # if you specify a color in the cfg for this asset, it will override the color
      # passed in by argument color.
      real_color = ((asset_options[:color].nil?) ? color : asset_options[:color])

      # the scale of the object
      # flip values (flip_h, flip_v) are xor'd with the flip value passed in by the config
      # TODO: Make flip decisions for non symetrical objects. that need to have bases 16 for each rotation and view
      scale_h = (flip_h ^ asset_options[:flip_h] ? -1.0 : 1.0)
      scale_v = (flip_v ^ asset_options[:flip_v] ? -1.0 : 1.0)

      # positional correction for the flip
      pcx = (flip_h ? width : 0)
      pcy = (flip_v ? height : 0)

      unless self[asset_name].respond_to? :draw
        "trap"
      end

      puts "rendering #{name}.#{asset_name}"

      #Access the asset and draw it
      self[asset_name].draw(x + pcx, y + pcy, 1, scale_h, scale_v, real_color)
    end
  end
end