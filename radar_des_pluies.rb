require "tempfile"

require "./script/meteo"

include Meteo::Radar

file = Tempfile.new(["meteo", ".img"], :encoding => "ascii-8bit")
file.write(get_last_radar_image + ESC_POS_CUT)
file.close
system("scp #{file.path} vega:/tmp")
system("ssh vega 'cat /tmp/#{File.basename(file)} > /dev/usb/lp0'")
