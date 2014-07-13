require "net/http"
require "tempfile"

module Meteo
  module Radar
    include Lib

    def get_radar_info(time)
      uri = URI.parse("http://www2.buienradar.nl/zoomin/49.5.1.5.#{"%d%02d%02d.%02d%02d" % [time.year, time.month, time.day, time.hour, time.min]}.eu.gif")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)

      if response.code == '200'
        file = Tempfile.new(['rain', '.gif'], :encoding => 'ascii-8bit')
        file.write(response.body)
        file.close

        file.path
      end
    end

    def construct_image(time)
      # convert staticmap.png 49.5.1.5.20131028.0115.eu.gif -composite -dither Riemersma -monochrome ploum.pbm

      radar_file = get_radar_info(time)
      if radar_file
        output_file = Tempfile.new(['rain', '.pbm'], :encoding => 'ascii-8bit')
        output_file.close
        ret = system("convert #{File.dirname(__FILE__)}/ile_de_france.png #{radar_file} -composite -dither Riemersma -monochrome #{output_file.path}")
        if ret
          print_image(output_file.path)
        end
      end
    end
  end
end
