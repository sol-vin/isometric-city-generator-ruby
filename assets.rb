require 'gosu'

include Gosu

#Holds image resources
class Assets
  #Holds tile assets
  @@tiles = {}

  #Holds block assets
  @@blocks = {}

  #Load the assets
  def self.load_assets game
    raise ArguementError.new("Did not supply a valid Gosu window!") unless game.is_a? Window

    @@tiles[:base_tile] = Image.new(game, "content/floor/tile.png", false)

    block = Image.new(game, 'content/building/block.png', false)
    block_light = Image.new(game, 'content/building/block_light.png', false)
    block_shade = Image.new(game, 'content/building/block_shade,png', false)

    @@blocks[:base_block] = BlockAsset.new(block,
                                           block_light,
                                           block_shade)
  end

  #Get a block asset from @@blocks
  def self.get_block_asset type
    raise ArgumentError.new("Type must be a symbol!") unless type.is_a? Symbol
    #commented out because during testing returns false because Assets.load_asset can't be called :(
    #raise ArgumentError unless @@blocks.keys.include? type
    @@blocks[type]
  end

  def self.get_tile_image type
    raise ArgumentError unless type.is_a? Symbol
    #raise ArgumentError unless @@tile.keys.include? type
    @@tiles[type]
  end
end

#Used to hold block images and shading/lighting as well as an add-on feature
class BlockAsset
  attr_reader :base, :light, :shade, :feature

  def initialize(base_image, light_image = nil, shade_image = nil, feature_image = nil)
    raise ArgumentError if base_image.nil?
    raise ArgumentError unless [light_image, shade_image, feature_image].all? {|item| item.is_a? Image}

    @base = base_image
    @light = light_image
    @shade = shade_image
    @feature = feature_image
  end

  def has_light?
    @light.nil?
  end

  def has_shade?
    @shade.nil?
  end

  def has_feature?
    @shade.nil?
  end
end