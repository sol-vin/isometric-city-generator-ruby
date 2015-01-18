#! /usr/bin/env ruby

require './assets.rb'
require './isometric_factory.rb'
require 'devil/gosu'
require 'method_profiler'

include Gosu

class Game < Window

  CAMERA_SPEED = 10

  def initialize
    super(1800, 1000, false)

    Gosu::enable_undocumented_retrofication

    Assets::load_assets self

    @camera = Point.new(0,0)

    @iso_factory = IsometricFactory.new(40, 40)
  end

  def update
    close if button_down? KbEscape
    if button_down? KbSpace
      @iso_factory.randomize
      @image = nil
    end

    @camera.x -= CAMERA_SPEED if button_down? KbRight
    @camera.x += CAMERA_SPEED if button_down? KbLeft

    @camera.y -= CAMERA_SPEED if button_down? KbDown
    @camera.y += CAMERA_SPEED if button_down? KbUp

    self.caption = "Isometric City Generator fps: #{Gosu.fps}"
  end

  def draw
    #draw first
    @image ||= record(1800, 1000) do
      @iso_factory.draw_grid
      @iso_factory.draw_blocks
    end
    translate(@camera.x, @camera.y) do
      @image.draw(0, 0, 1)
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

profiler = MethodProfiler.observe(IsometricFactory)
Game.new.show
puts profiler.report

