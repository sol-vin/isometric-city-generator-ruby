#! /usr/bin/env ruby

require './key.rb'
require './assets.rb'
require './isometric_factory.rb'
require './perlin_factory.rb'
require './city_factory.rb'

require 'method_profiler'

require 'gosu'

class Game < Gosu::Window

  CAMERA_SPEED = 10
  SIZE_X = 50
  SIZE_Y = 50
  def initialize
    super(1800, 1000, false)

    Gosu::enable_undocumented_retrofication

    Assets::load_assets

    @camera = Vector2.new(0,0)
    @generators = [PerlinFactory, CityFactory]
    @generator = 0

    @factory = @generators[@generator].new(rand(1000000), SIZE_X, SIZE_Y)

    @render_mode = :draw_easy

    @close_button = Key.new Gosu::KbEscape
    @random_button = Key.new Gosu::KbSpace
    @next_view_button = Key.new Gosu::KbA
    @last_view_button = Key.new Gosu::KbS
    @draw_easy_button = Key.new Gosu::KbG
    @draw_hard_button = Key.new Gosu::KbH
    @rotate_cw_button = Key.new Gosu::KbQ
    @rotate_ccw_button = Key.new Gosu::KbW
  end

  def update
    Key.update_keys self

    close if @close_button.is_down?

    if @random_button.was_pressed?
      @factory.seed = rand(10000)
      @image = nil
    end

    @camera.x -= CAMERA_SPEED if button_down? Gosu::KbRight
    @camera.x += CAMERA_SPEED if button_down? Gosu::KbLeft

    @camera.y -= CAMERA_SPEED if button_down? Gosu::KbDown
    @camera.y += CAMERA_SPEED if button_down? Gosu::KbUp

    if @next_view_button.was_pressed?
      @generator += 1
      @generator = 0 if @generator > @generators.length-1
      @image = nil
      view = @factory.view
      @factory = @generators[@generator].new(@factory.seed, SIZE_X, SIZE_Y)
      @factory.view = view
    end

    if @last_view_button.was_pressed?
      @generator -= 1
      @generator = @generators.length-1 if @generator < 0
      @image = nil
      view = @factory.view
      @factory = @generators[@generator].new(@factory.seed, SIZE_X, SIZE_Y)
      @factory.view = view
    end

    if @draw_hard_button.was_pressed?
      @render_mode = :draw_hard
    end

    if @draw_easy_button.was_pressed?
      @render_mode = :draw_easy
    end

    if @rotate_ccw_button.was_pressed?
      @factory.rotate_counter_clockwise
      @image = nil
    end

    if @rotate_cw_button.was_pressed?
      @factory.rotate_clockwise
      @image = nil
    end

    self.caption = "Isometric Generator fps: #{Gosu.fps} rm: #{@render_mode} gen: #{@generator} seed: #{@factory.seed} view: #{@factory.view}"

    Key.post_update_keys self
  end

  def draw
    #draw first
    send @render_mode
  end

  def draw_easy
    @image ||= record(1, 1) do
      @factory.draw_grid
      @factory.draw_blocks
    end
    translate(@camera.x, @camera.y) do
      @image.draw(0, 0, 1)
    end
  end

  def draw_hard
    translate(@camera.x, @camera.y) do
      @factory.draw_grid
      @factory.draw_blocks
    end
  end
end

#profiler = MethodProfiler.observe(IsometricFactory)
Game.new.show
#puts profiler.report

