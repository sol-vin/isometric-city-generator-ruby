#! /usr/bin/env ruby

require 'rubygems'
require 'gosu'
require './assets.rb'
require './isometric_object.rb'
require './isometric_factory.rb'
include Gosu

class Game < Gosu::Window

  def initialize
    super(800, 400, false)
    self.caption = "Isometric City Generator"

    Assets::load_assets self

    @iso_factory = IsometricFactory.new
  end

  def update

  end

  def draw
    20.times do |x|
      20.times do |y|
        pos = @iso_factory.get_tile_position(x, y)
        Assets.get_tile_image(:base_tile).draw(pos.x, pos.y, 1)
      end
    end
  end
end

Game.new.show

