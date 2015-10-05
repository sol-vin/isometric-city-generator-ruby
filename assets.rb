require 'rubygems'
require 'gosu'

require './block_asset.rb'

#Holds image resources
class Assets
  #On use of class level variables
  #   These are safe because you are not allowed to inherit Assets
  #   See inherited hook @ bottom of class definition

  #Holds tile assets
  @@tiles = {}

  #Holds block assets
  @@blocks = {}

  #holds feature assets
  @@features = {}

  #Load the assets
  def self.load_assets
    content_path = File.dirname(File.absolute_path(__FILE__)) + '/content/'
    Dir.entries(content_path).each do |folder|
      next if folder =~ /^\.*$/

      Dir.entries(content_path + folder).each do |filename|
        next if filename =~ /^\.*$/
        name = filename.split('.').first.to_sym
        if(folder == 'blocks')

          #check to see of if image exists
          base, light, shade, feature = nil

          #try to assign images if they exist
          blocks_path = content_path + 'blocks/' + name.to_s + '/'
          base = Gosu::Image.new(blocks_path + "#{name}.png") if File.exists? (blocks_path + "#{name}.png")
          light = Gosu::Image.new(blocks_path + "#{name}_light.png") if File.exists? (blocks_path + "#{name}_light.png")
          shade = Gosu::Image.new(blocks_path + "#{name}_shade.png") if File.exists? (blocks_path + "#{name}_shade.png")
          feature = Gosu::Image.new(blocks_path + "#{name}_feature.png") if File.exists? (blocks_path + "#{name}_feature.png")

          @@blocks[name] = BlockAsset.new(base, light, shade, feature)
        else
          class_variable_get('@@' + folder)[name] = Gosu::Image.new(content_path + folder + '/' + filename)
        end
      end
    end
    true
  end

  def self.roads
    @@tiles.keys.select {|key| key.to_s =~ /^road/}
  end

  def self.rooves
    @@blocks.keys.select {|key| key.to_s =~ /^roof/}
  end

  def self.windows
    @@features.keys.select {|key| key.to_s =~ /^window/}
  end

  def self.doors
    @@features.keys.select {|key| key.to_s =~ /^door/}
  end

  def self.is_type_buildable? type
    !(roads.include?(type) || roofs.include?(type) || type.nil?)
  end

  def self.get_feature_image type
    @@features[type]
  end

  #Get a block asset from @@blocks
  def self.get_block_asset type
    @@blocks[type]
  end

  def self.get_tile_image type
    @@tiles[type]
  end

  def self.block_width
    @@blocks[:block].width
  end

  def self.block_height
    @@blocks[:block].height
  end

  def self.tile_width
    @@tiles[:tile].width
  end

  def self.tile_height
    @@tiles[:tile].height
  end

  #Stops class from being inherited. (sealed in C#)
  def self.inherited base
    raise RuntimeError.new 'You are not allowed to inherit the Assets class!'
  end
end

#I love this in ruby, write a struct, then have it automagically
#write all the arithmetic for you.
class Vector2 < Struct.new(:x, :y)
  def method_missing(name, *args)
    #Check to see if the method name is one char long
    #If so, it's most likely an operation like +, -, *, /
    #Just in case there is a one letter method,
    #also check to ensure there is only one arg
    if(name.length == 1 && args.length == 1)
      Vector2.new(x.send(name, args.first.x), y.send(name, args.first.y))
    end
  end

  class << self
    def one
      Vector2.new(1, 1)
    end
    
    def zero
      Vector2.new(0, 0)
    end
  end
end

class Vector3 < Struct.new(:x, :y, :z)
  def method_missing(name, *args)
    #Check to see if the method name is one char long
    #If so, it's most likely an operation like +, -, *, /
    #Just in case there is a one letter method,
    #also check to ensure there is only one arg
    if(name.length == 1 && args.length == 1)
      Vector3.new(x.send(name, args.first.x), y.send(name, args.first.y), z.send(name, args.first.z))
    end
  end

  class << self
    def one
      Vector3.new(1, 1, 1)
    end
    
    def zero
      Vector3.new(0, 0, 0)
    end
  end
end


#Monkey patch numeric to be useful
class Numeric
  def clamp min, max
    [[self, max].min, min].max
  end
end
