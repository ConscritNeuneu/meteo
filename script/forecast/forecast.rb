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
        dates = xml.xpath("//div[@id='table_ephem'][1]").first
        date = dates.xpath(".//span[@class='date'][1]").first.text
        maj = dates.xpath(".//span[@class='miseajour'][1]").first.text.strip

        previsions = xml.xpath("//div[@id='table_prevision'][1]").first
        titles = previsions.xpath('table/tr[1]/th/div').slice(0, 4).map(&:text)
        pictos = previsions.xpath('table/tr[2]//img').slice(0, 4).map { |node| node.attribute("src").value.sub(/.*\//, "") }
        temps = previsions.xpath('table/tr[3]//div').slice(0, 4).map do |node|
          [
            node.children.first.text.strip,
            node.xpath('span').text.strip
          ]
        end
        text = previsions.xpath('table/tr[4]//p').first.text

        {
          :titles => titles,
          :pictos => pictos,
          :temps => temps.map { |t| t[0] },
          :old_temps => temps.map { |t| t[1] },
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

            pictos = group.map { |i| ImageList.new(File.dirname(__FILE__) + "/assets/" + data[:pictos][i]).first }
              .map { |img| img.change_geometry("200") { |cols, rows, img_| img_.resize(cols, rows) } }

            resulting_image = compose_pictos(*pictos)
              .threshold(0.70 * MaxRGB).quantize(2)
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
