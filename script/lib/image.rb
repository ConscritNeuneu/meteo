module Meteo
  module Lib
    def load_image(pbm_image)
      pbm_file = StringIO.new(pbm_image)
      format = pbm_file.gets.chomp
      width, height = pbm_file.gets.chomp.split.map { |i| i.to_i }
      bits = pbm_file.read.unpack("C*")
      pbm_file.close

      Bitmap.new(bits, width, height)
    end

    def print_image(pbm_image)
      load_image(pbm_image).print_bitmap
    end
  end
end
