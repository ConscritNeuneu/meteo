require "RMagick"

module Meteo
  module Radar
    include Lib
    include Magick

    def construct_image(time)
      url = "http://www2.buienradar.nl/zoomin/49.5.1.5.#{"%d%02d%02d.%02d%02d" % [time.year, time.month, time.day, time.hour, time.min]}.eu.gif"
      radar_data = get_url(url)
      if radar_data
        radar = Image.from_blob(radar_data).first
        idf = ImageList.new("#{File.dirname(__FILE__)}/ile_de_france.png").first
        composed_image = idf.composite(radar, 0, 0, OverCompositeOp).quantize(2)
        composed_image.format = "PBM"
        print_image(composed_image.to_blob)
      end
    end

    def get_last_radar_image
      time = Time.now - (900)
      time = time - time.tv_sec % (900)

      out = (ESC_POS_CENTER + ESC_POS_CP_1252 + "Radar des pluies \u00e0 #{time}\n".encode(Encoding::WINDOWS_1252)).force_encoding(Encoding::ASCII_8BIT)
      out + construct_image(time)
    end
  end
end
