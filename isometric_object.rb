require 'gosu'

include Gosu

class IsometricObject
  attr_reader :block_asset
  attr_reader :type
  attr_accessor :x, :y
  attr_accessor :color
  attr_accessor :flip

  def initialize(block_type, opts_hash = nil)
    @block_asset = Assets.get_block_asset block_type

    #defaults
    @x = 0
    @y = 0
    @color = Gosu::Color::WHITE
    @flip = :none


    #ensure all the opts in opts_hash are legit
    raise ArgumentError.new("Option hash contained keys that do not exist!") unless opts_hash.keys.all? {|opt| respond_to? (opt.to_s+'=').to_sym}

    #parse the opts_hash
    opts_hash.each { |opt, value| send((opt.to_s+'=').to_sym, value) } unless opts_hash.nil?
  end

  def buildable?

  end

  def draw
    @block_asset.base.draw(x, y, 1, 1, 1, color)
    @block_asset.light.draw(x, y, 1) if @block_asset.has_light?
    @block_asset.shade.draw(x, y, 1) if @block_asset.has_shade?
    @block_asset.feature.draw(x, y, 1) if @block_asset.has_feature?
  end
end