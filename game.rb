#! /usr/bin/env ruby

require './assets.rb'
require './isometric_object.rb'
require './isometric_factory.rb'

include Gosu

class Game < Window
  def initialize
    super(800, 400, false)
    self.caption = "Isometric City Generator"

    Assets::load_assets self

    @iso_factory = IsometricFactory.new(20, 20)
  end

  def update

  end

  def draw
    puts @iso_factory.instance_variable_get(:@spacing)
    @iso_factory.draw_grid
    @iso_factory.draw_blocks
  end
end

Game.new.show

