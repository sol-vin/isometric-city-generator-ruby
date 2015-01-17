require './assets.rb'

class IsometricObject
  attr_reader :type
  attr_reader :color
  attr_reader :flip

  def initialize(type, opts_hash = nil)

    @type = type

    #defaults
    @color = Gosu::Color::WHITE
    @flip = :none


    #ensure all the opts in opts_hash are legit
    raise ArgumentError.new("Option hash contained keys that do not exist!") unless opts_hash.nil? || opts_hash.keys.all? {|opt| respond_to? (opt.to_s+'=').to_sym}

    #parse the opts_hash
    opts_hash.each { |opt, value| send((opt.to_s+'=').to_sym, value) } unless opts_hash.nil?
  end

  def buildable?

  end

  def draw

  end
end