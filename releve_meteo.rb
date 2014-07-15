require "tempfile"

require "./script/meteo"

include Meteo::Forecast
include Meteo::Radar
include Meteo::TempChart

file = Tempfile.new(["meteo", ".img"], :encoding => "ascii-8bit")
file.write(get_forecast)
file.write("-" * 48 + "\n")
file.write(get_last_radar_image)
file.write("-" * 48 + "\n")
file.write(get_last_temp_chart)
file.write(ESC_POS_CUT)
file.close
system("scp #{file.path} vega:/tmp")
system("ssh vega 'cat /tmp/#{File.basename(file)} > /dev/usb/lp0'")
