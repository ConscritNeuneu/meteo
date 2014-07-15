require "tempfile"

require "./script/meteo"

include Meteo::Forecast
include Meteo::Radar
include Meteo::TempChart

File.open("/dev/usb/lp0", "wb") do |printer|
  printer.write(get_forecast)
  printer.write("-" * 48 + "\n")
  printer.write(get_last_radar_image)
  printer.write("-" * 48 + "\n")
  printer.write(get_last_temp_chart)
  printer.write(ESC_POS_CUT)
end
