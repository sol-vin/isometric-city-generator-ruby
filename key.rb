class Key
  @@keys = []

  def self.update_keys window
    @@keys.each {|key| key.update window}
  end

  def self.post_update_keys window
    @@keys.each {|key| key.post_update window}
  end

  attr_reader :key, :last, :current

  def initialize key
    @key = key
    @@keys << self
  end

  def update window
    @current = window.button_down? key
  end

  def post_update window
    @last = @current
  end

  def was_released?
    last && !current
  end

  def was_pressed?
    current && !last
  end

  def is_down?
    current
  end

  def is_up?
    !current
  end
end