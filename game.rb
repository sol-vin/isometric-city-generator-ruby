#! /usr/bin/env ruby

require './key.rb'
require './assets.rb'
require './isometric_factory.rb'
require './perlin_factory.rb'
require './city_factory.rb'

require 'method_profiler'

include Gosu

class Game < Window

  CAMERA_SPEED = 10
  SIZE_X = 50
  SIZE_Y = 50
  def initialize
    super(1800, 1000, false)

    Gosu::enable_undocumented_retrofication

    Assets::load_assets self

    @camera = Point.new(0,0)

    @iso_factory = CityFactory.new(rand(10000), SIZE_X, SIZE_Y)
    @render_mode = :draw_easy

    @close_button = Key.new KbEscape
    @random_button = Key.new KbSpace
    @perlin_button = Key.new KbP
    @city_button = Key.new KbO
    @draw_easy_button = Key.new KbG
    @draw_hard_button = Key.new KbH
    @rotate_cw_button = Key.new KbQ
    @rotate_ccw_button = Key.new KbW
  end

  def update
    Key.update_keys self

    close if @close_button.is_down?

    if @random_button.was_pressed?
      @iso_factory.seed = rand(10000)
      @image = nil
    end

    @camera.x -= CAMERA_SPEED if button_down? KbRight
    @camera.x += CAMERA_SPEED if button_down? KbLeft

    @camera.y -= CAMERA_SPEED if button_down? KbDown
    @camera.y += CAMERA_SPEED if button_down? KbUp

    if @perlin_button.was_pressed?
      @iso_factory.draw_mode = :perlin
      @image = nil
    end

    if @city_button.was_pressed?
      @iso_factory.draw_mode = :city
      @image = nil
    end

    if @draw_hard_button.was_pressed?
      @render_mode = :draw_hard
    end

    if @draw_easy_button.was_pressed?
      @render_mode = :draw_easy
    end

    if @rotate_ccw_button.was_pressed?
      @iso_factory.rotate_counter_clockwise
      @image = nil
    end

    if @rotate_cw_button.was_pressed?
      @iso_factory.rotate_clockwise
      @image = nil
    end

    self.caption = "Isometric City Generator fps: #{Gosu.fps} rm: #{@render_mode} seed: #{@iso_factory.seed}"

    Key.post_update_keys self
  end

  def draw
    #draw first
    send @render_mode
  end

  def draw_easy
    @image ||= record(1, 1) do
      @iso_factory.draw_grid
      @iso_factory.draw_blocks
    end
    translate(@camera.x, @camera.y) do
      @image.draw(0, 0, 1)
    end
  end

  def draw_hard
    translate(@camera.x, @camera.y) do
      @iso_factory.draw_grid
      @iso_factory.draw_blocks
    end
  end
end

#profiler = MethodProfiler.observe(IsometricFactory)
Game.new.show
#puts profiler.report

