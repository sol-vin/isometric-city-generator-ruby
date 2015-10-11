require './isometric_asset.rb'

class IsometricAssets
  attr_reader :assets, :alias



  def initialize(name)

    @assets = {}
    @alias = {}

    add_content name
  end

  def add_content(assets_name)
    content_path = File.dirname(File.absolute_path(__FILE__)) + "/content/#{assets_name}/"
    Dir.entries(content_path).each do |folder|
      next if folder =~ /^\.*$/

      Dir.entries(content_path + folder).each do |filename|
        next if filename =~ /^\.*$/
        name = filename.split('.').first.to_sym

        puts "loading #{assets_name}/#{name} from #{content_path + folder + '/' + filename}"

        #check to see of if image exists
        base, light, shade, feature = nil

        #try to assign images if they exist
        blocks_path = content_path + "#{folder}/" + name.to_s + '/'
        puts blocks_path

        base = Gosu::Image.new(blocks_path + "#{name}.png") if File.exists? (blocks_path + "#{name}.png")
        light = Gosu::Image.new(blocks_path + "#{name}_light.png") if File.exists? (blocks_path + "#{name}_light.png")
        shade = Gosu::Image.new(blocks_path + "#{name}_shade.png") if File.exists? (blocks_path + "#{name}_shade.png")
        feature = Gosu::Image.new(blocks_path + "#{name}_feature.png") if File.exists? (blocks_path + "#{name}_feature.png")

        @assets[name] = IsometricAsset.new(base, light, shade, feature)
        puts "loaded block texture #{name} from #{blocks_path}"
      end
    end
    true
  end

  def add_alias(key, asset)
    @alias[key] = asset
  end

  def remove_alias(key)
    @alias[key] = nil
  end

  def roads
    @assets.keys.select {|key| key.to_s =~ /^road/}
  end

  def roofs
    @assets.keys.select {|key| key.to_s =~ /^roof/}
  end

  def windows
    @features.keys.select {|key| key.to_s =~ /^window/}
  end

  def doors
    @features.keys.select {|key| key.to_s =~ /^door/}
  end

  def trees
    @assets.keys.select {|key| key.to_s =~ /^trees/}
  end

  def tiles
    @assets.keys.select {|key| @assets[key].height = tile_height}
  end

  def blocks
    @assets.keys.select {|key| @assets[key].height = block_height}
  end

  def get_feature_image type
    @assets[type]
  end

  #Get a block asset from @@blocks
  def get_asset type
    return @assets[type] unless @assets[type] == nil
    return @assets[@alias[type]]
  end


  def block_width
    @assets[:block].width
  end

  def block_height
    @assets[:block].height
  end

  def tile_width
    @assets[:tile].width
  end

  def tile_height
    @assets[:tile].height
  end
end