module Meteo
  module Lib
    def load_image(image_file)
      File.open(image_file, "rb") do |file|
        format = file.gets.chomp
        width, height = file.gets.chomp.split.map { |i| i.to_i }
        bits = file.read.unpack("C*")

        Bitmap.new(bits, width, height)
      end
    end

    def print_image(image_file)
      load_image(image_file).print_bitmap
    end
  end
end
