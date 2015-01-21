class Key
  attr_reader :key, :last, :current

  def initialize key
    @key = key
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