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
  SIZE_X = 100
  SIZE_Y = 100
  def initialize
    super(1800, 1000, false)

    Gosu::enable_undocumented_retrofication

    Assets::load_assets self

    @camera = Point.new(0,0)

    @seed = rand(10000)
    @iso_factory = PerlinFactory.new(@seed, SIZE_X, SIZE_Y)
    @render_mode = :draw_easy

    @close_button = Key.new KbEscape
    @random_button = Key.new KbSpace
    @perlin_button = Key.new KbP
    @city_button = Key.new KbO
    @draw_easy_button = Key.new KbG
    @draw_hard_button = Key.new KbH
  end

  def update_keys


    @close_button.update self
    @random_button.update self
    @perlin_button.update self
    @city_button.update self
    @draw_easy_button.update self
    @draw_hard_button.update self
  end

  def post_update_keys
    @close_button.post_update self
    @random_button.post_update self
    @perlin_button.post_update self
    @city_button.post_update self
    @draw_easy_button.post_update self
    @draw_hard_button.post_update self
  end

  def update
    update_keys

    close if @close_button.is_down?

    if @random_button.was_pressed?
      @seed = rand(10000)
      @iso_factory = @iso_factory.class.new(@seed, SIZE_X, SIZE_Y)
      @image = nil
    end

    @camera.x -= CAMERA_SPEED if button_down? KbRight
    @camera.x += CAMERA_SPEED if button_down? KbLeft

    @camera.y -= CAMERA_SPEED if button_down? KbDown
    @camera.y += CAMERA_SPEED if button_down? KbUp

    if @perlin_button.was_pressed?
      @iso_factory = PerlinFactory.new(@seed, SIZE_X, SIZE_Y)
      @image = nil
    end

    if @city_button.was_pressed?
      @iso_factory = CityFactory.new(@seed, SIZE_X, SIZE_Y)
      @image = nil
    end

    if @draw_hard_button.was_pressed?
      @render_mode = :draw_hard
    end

    if @draw_easy_button.was_pressed?
      @render_mode = :draw_easy
    end

    self.caption = "Isometric City Generator fps: #{Gosu.fps} rm: #{@render_mode}"

    post_update_keys
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

