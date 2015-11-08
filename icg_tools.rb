#require './isometric_asset.rb'
require './monkey_patch'
require 'yaml'

class ICGTools
  def self.make_texture_config(base, light, shade, light_side)

  end

  def self.read_texture_config(filename)
    file = File.open(filename)
    yaml_dump = Hash.keys_to_sym YAML.load(file.read)
    file.close
    yaml_dump
  end
end