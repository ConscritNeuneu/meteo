require "tempfile"

require "./script/meteo"

include Meteo::Forecast
include Meteo::Radar
include Meteo::TempChart

def releve_meteo
  [
    ESC_POS_INIT,
    get_forecast,
    "-" * 48 + "\n",
    get_last_radar_image,
    "-" * 48 + "\n",
    get_last_temp_chart,
    ESC_POS_CUT
  ].join
end


File.open("/dev/usb/lp0", "wb") do |printer|
  printer.write(releve_meteo)
end
