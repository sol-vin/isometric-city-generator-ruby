#Used to hold block images and shading/lighting as well as an add-on feature
class BlockAsset
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

  def draw(position, z_order, color)
    base.draw(position.x, position.y, z_order, 1, 1, color)
    light.draw(position.x, position.y, z_order, 1, 1, 0x08ffffff) if has_light?
    shade.draw(position.x, position.y, z_order, 1, 1, 0x08ffffff) if has_shade?
    feature.draw(position.x, position.y, z_order, 1, 1, 0xffffffff) if has_feature?
  end
end