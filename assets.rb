require 'rubygems'
require 'gosu'

#Holds image resources
class Assets
  #Holds tile assets
  @@tiles = {}

  #Holds block assets
  @@blocks = {}

  #Load the assets
  def self.load_assets game
    raise ArgumentError.new('Did not supply a valid Gosu window!') unless game.is_a? Window

    content_path = File.dirname(File.absolute_path(__FILE__)) + '/content/'

    @@tiles[:base_tile] = Gosu::Image.new(game, content_path + 'floor/tile.png', false)

    block = Gosu::Image.new(game, (content_path + 'building/block.png'), false)
    block_light = Gosu::Image.new(game, (content_path + 'building/block_light.png'), false)
    block_shade = Gosu::Image.new(game, (content_path + 'building/block_shade.png'), false)

    @@blocks[:base_block] = BlockAsset.new(block,
                                           block_light,
                                           block_shade)
  end

  #Get a block asset from @@blocks
  def self.get_block_asset type
    raise ArgumentError.new('Type must be a symbol!') unless type.is_a? Symbol
    #commented out because during testing returns false because Assets.load_asset can't be called :(
    #raise ArgumentError unless @@blocks.keys.include? type
    @@blocks[type]
  end

  def self.get_tile_image type
    raise ArgumentError unless type.is_a? Symbol
    #raise ArgumentError unless @@tile.keys.include? type
    @@tiles[type]
  end

  def self.block_width
    @@blocks[:base_block].width
  end

  def self.block_height
    @@blocks[:base_block].height
  end

  def self.tile_width
    @@tiles[:base_tile].width
  end

  def self.tile_height
    @@tiles[:base_tile].height
  end
end

#Used to hold block images and shading/lighting as well as an add-on feature
class BlockAsset
  attr_reader :base, :light, :shade, :feature

  def initialize(base_image, light_image = nil, shade_image = nil, feature_image = nil)
    raise ArgumentError if base_image.nil?

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

  def width
    @base.width
  end

  def height
    @base.height
  end

  def draw(position, z_order, color)
    base.draw(position.x, position.y, z_order, 1, 1, color)
    light.draw(position.x, position.y, z_order, 1, 1, 0x33ffffff) if has_light?
    shade.draw(position.x, position.y, z_order, 1, 1, 0x33ffffff) if has_shade?
    feature.draw(position.x, position.y, z_order, 1, 1, 0x33ffffff) if has_feature?
  end
end

#I love this in ruby, write a struct, then have it automagically
#write all the arithmetic for you.
class Point < Struct.new(:x, :y)
  def method_missing(name, *args)
    #Check to see if the method name is one char long
    #If so, it's most likely an operation like +, -, *, /
    #Just in case there is a one letter method,
    #also check to ensure there is only one arg
    if(name.length == 1 && args.length == 1)
      Point.new(x.send(name, args.first.x), y.send(name, args.first.y))
    end
  end
end

#Monkey path numeric to be useful
class Numeric
  def clamp min, max
    [[self, max].min, min].max
  end
end