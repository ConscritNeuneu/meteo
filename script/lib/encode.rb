module Meteo
  module Lib

    def encode_1252(text)
      ESC_POS_CP_1252 + text.encode(Encoding::WINDOWS_1252).force_encoding(Encoding::ASCII_8BIT)
    end

  end
end
