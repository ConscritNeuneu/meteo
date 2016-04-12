require "RMagick"
require "nokogiri"

module Meteo
  module Forecast
    include Lib
    include Magick

    def fetch_previsions
      meteo_paris = get_url("http://www.meteo-paris.com/")
      if meteo_paris
        xml = Nokogiri::HTML.parse(meteo_paris).remove_namespaces!
        site = xml.xpath("//div[@id='site'][1]").first
        maj = site.xpath(".//div[@class='site_prevision_bloc_miseajour'][1]").first.text.strip

        previsions = site.xpath(".//div[@id='prevision'][1]").first
        date = previsions.xpath(".//span[@id='date_accueil'][2]").first.text.strip
        cases = previsions.xpath(".//div[@class='ac_picto_ensemble']").map do |case_prev|
          {
            :title => case_prev.xpath("div[@class='ac_etiquette']").text,
            :picto => case_prev.xpath("div[@class='ac_picto']/img").first.attribute("src").value.sub(/.*\/(.*)\..*/, '\1'),
            :temp => case_prev.xpath("div[@class='ac_temp']").first.children.first.text.strip + "\u00B0 C",
            :old_temp => case_prev.xpath("span[@class='temperature_hier']").text,
          }
        end
        text = previsions.xpath(".//div[@class='ac_com']").first.text.strip

        {
          :titles => cases.map { |c| c[:title] },
          :pictos => cases.map { |c| c[:picto] },
          :temps => cases.map { |c| c[:temp] },
          :old_temps => cases.map { |c| c[:old_temp] },
          :text => text,
          :date => date,
          :maj => maj
        }
      end
    end

    def compose_pictos(*pictos)
      list = ImageList.new
      pictos.each { |p| list << p }

      list.reduce do |prev_image, image|
        old_rectangle = prev_image.page
        rectangle = image.page

        rectangle[:x] = old_rectangle[:width] + old_rectangle[:x] + 88

        image.page = rectangle

        image
      end
      list.mosaic
    end

    def align_words(words, length = ESC_POS_LINE_LENGTH)
      size_by_word = length / words.length

      words.map do |word|
        left = " " * ((size_by_word - word.length) / 2) + word
        right = " " * (size_by_word - left.length)
        left + right
      end.join
    end

    def wrap_text(text)
      text.gsub(/(.{1,#{ESC_POS_LINE_LENGTH}})(\s+|\Z)/, "\\1\n")
    end

    def get_forecast
      data = fetch_previsions
      if data
        [
          ESC_POS_EMPH,
          encode_1252("BULLETIN DU #{data[:date]}\n"),
          ESC_POS_NORM,
          ESC_POS_FONT_B,
          encode_1252("#{data[:maj]}\n"),
          ESC_POS_FONT_A,
          "-" * (3 * ESC_POS_LINE_LENGTH / 4) + "\n",
          ESC_POS_LEFT,
          encode_1252(wrap_text(data[:text])),
          ESC_POS_CENTER,
          "-" * (3 * ESC_POS_LINE_LENGTH / 4) + "\n",
          [[0, 1], [2, 3]].map do |group|
            moments = align_words(group.map { |i| data[:titles][i] })

            temps = align_words(group.map { |i| data[:temps][i] })
            old_temps = align_words(group.map { |i| data[:old_temps][i] }, ESC_POS_LINE_LENGTH_B)

            pictos = group.map { |i| ImageList.new(File.dirname(__FILE__) + "/assets/" + data[:pictos][i] + ".png").first }
              .map { |img| img.change_geometry("200") { |cols, rows, img_| img_.resize(cols, rows) } }

            resulting_image = compose_pictos(*pictos)
              .threshold(0.60 * MaxRGB).quantize(2)
            resulting_image.format = "PBM"

            [
              encode_1252(moments) + "\n",
              print_image(resulting_image.to_blob),
              encode_1252(temps) + "\n",
              ESC_POS_FONT_B,
              encode_1252(old_temps) + "\n",
              ESC_POS_FONT_A
            ].join
          end.join("-" * (3 * ESC_POS_LINE_LENGTH / 4) + "\n")
        ].join
      end
    end

  end
end
