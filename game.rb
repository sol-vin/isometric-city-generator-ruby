require 'gosu'
require './assets.rb'
require './isometric_object.rb'

include Gosu

class Game < Window

  def initialize
    super(640, 800, false)
    self.caption = "Isometric City Generator"

    Assets::load_assets self

    @iso_object = IsometricObject.new(:base_block, {x: 40, y: 40})
  end

  def update

  end

  def draw
    @iso_object.draw
  end
end

Game.new.show