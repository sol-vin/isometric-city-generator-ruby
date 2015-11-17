require './block.rb'

class Chunk
  attr_reader :blocks
  attr_reader :size_x, :size_y, :size_z

  def initialize(size_x, size_y, size_z)
    @size_x = size_x
    @size_y = size_y
    @size_z = size_z

    clear
  end

  def clear
    @blocks = Array.new(size_x, Array.new(size_y, Array.new(size_z)))
  end

  def read_from_file filename
    file = File.open(filename, "r")
    chunk = Marshal.load(file.read)
    file.close
    chunk
  end

  def write_to_file filename
    file = File.new(filename, "w")
    file.write(Marshall.dump(self))
    file.close
  end
end