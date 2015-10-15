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
end