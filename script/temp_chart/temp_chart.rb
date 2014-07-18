require "RMagick"

module Meteo
  module TempChart
    include Lib
    include Magick

    def get_last_temp_chart
      chart_gif = get_url("http://static.meteo-paris.com/station/OutsideTempHistory.gif")
      if chart_gif
        # 576 pixels max
        pbm_chart = Image.from_blob(chart_gif).first.change_geometry("480") do |cols, rows, img|
          img.resize(cols, rows)
        end.threshold(0.70 * MaxRGB).quantize(2)
        pbm_chart.format = "PBM"

        out = ESC_POS_CENTER + encode_1252("Derniers relev\u00E9s de temperature\n")
        out + print_image(pbm_chart.to_blob)
      end
    end

  end
end
