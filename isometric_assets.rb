require './isometric_asset.rb'
require './icg_tools.rb'

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
      next if folder =~ /^\.*$/ #Returns . and . .as folders smh
      name = folder.to_sym
      puts "loading #{assets_name}/#{folder} from #{content_path + folder}"

      #try to assign images if they exist
      blocks_path = content_path + "#{folder}/"
      puts blocks_path

      #make the initial asset,
      asset = IsometricAsset.new folder, ICGTools.read_texture_config(blocks_path + 'cfg')

      #go through each image in the asset folder
      Dir.entries(blocks_path).each do |image_file|
        next if image_file =~ /^\.*$/ #stops . and . . as folders
        next if image_file == 'cfg' #ignore the configuration file
        image_tag = image_file.split('.').first.to_sym #grab the tag out of the filename
        asset.load_asset(image_tag, blocks_path + image_file) #load the tag and image into the asset
      end
      @assets[name] = asset
      puts "loaded block texture #{name} from #{blocks_path},had tags #{asset.keys}"
    end
    true
  end

  def from_collection(tag)
    @assets.keys.select {|k| get_asset(k).config[:collections].include? tag}
  end
  alias f_c from_collection

  def add_alias(key, asset)
    @alias[key] = asset
  end

  def remove_alias(key)
    @alias[key] = nil
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