#Used to hold block images and shading/lighting as well as an add-on feature
class IsometricAsset
  attr_reader :base, :light, :shade, :feature

  def initialize(base_image, light_image = nil, shade_image = nil, feature_image = nil)
    raise ArgumentError if base_image.nil?

    @base = base_image
    @light = light_image
    @shade = shade_image
    @feature = feature_image
  end

  def has_light?
    !@light.nil?
  end

  def has_shade?
    !@shade.nil?
  end

  def has_feature?
    !@feature.nil?
  end

  def width
    @base.width
  end

  def height
    @base.height
  end

  def draw(position, color, flip_h, flip_v)

    scale_h = (flip_h ? -1.0 : 1.0)
    scale_v = (flip_v ? -1.0 : 1.0)

    pcx = (flip_h ? width : 0)
    pcy = (flip_v ? height : 0)

    base.draw(position.x + pcx, position.y + pcy, 1, scale_h, scale_v, color)
    light.draw(position.x + pcx, position.y + pcy, 1, scale_h, scale_v, 0x10ffffff) if has_light?
    shade.draw(position.x + pcx, position.y + pcy, 1, scale_h, scale_v, 0x10ffffff) if has_shade?
    feature.draw(position.x + pcx, position.y + pcy, 1, scale_h, scale_v, 0xffffffff) if has_feature?
  end
end