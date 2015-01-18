#! /usr/bin/env ruby

require './assets.rb'
require './isometric_object.rb'
require './isometric_factory.rb'

include Gosu

class Game < Window

  CAMERA_SPEED = 10

  def initialize
    super(1800, 1000, false)

    Gosu::enable_undocumented_retrofication

    Assets::load_assets self

    @camera = Point.new(0,0)

    @iso_factory = IsometricFactory.new(50, 50)
  end

  def update
    exit if button_down? KbEscape
    @iso_factory.randomize if button_down? KbSpace

    @camera.x -= CAMERA_SPEED if button_down? KbRight
    @camera.x += CAMERA_SPEED if button_down? KbLeft

    @camera.y -= CAMERA_SPEED if button_down? KbDown
    @camera.y += CAMERA_SPEED if button_down? KbUp

    self.caption = "Isometric City Generator fps: #{Gosu.fps}"
  end

  def draw
    translate(@camera.x, @camera.y) do
      @iso_factory.draw_grid
      @iso_factory.draw_blocks
      #draw_vision_test
    end
  end

  def draw_vision_test
    position = IsometricFactory.get_block_position(0,0,0)
    Assets.get_block_asset(:base_block).draw(position, 1, 0xffffffff)

    1.times do |z|
      position = IsometricFactory.get_block_position(1, 1, z)
      Assets.get_block_asset(:base_block).draw(position, 1, 0xffffffff)
    end
  end
end

Game.new.show

