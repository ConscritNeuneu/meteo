require "RMagick"

module Meteo
  module Header
    include Lib
    include Magick

    def header
      img = ImageList.new("#{File.dirname(__FILE__)}/blubby.png").first.quantize(2)
      img.format = "PBM"
      print_image(img.to_blob)
    end
  end
end
