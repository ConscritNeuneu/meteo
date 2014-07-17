module Meteo
  module Lib

    ESC_POS_LINE_LENGTH = 48
    ESC_POS_LINE_LENGTH_B = 64
    ESC_POS_PIXELS = 576

    ESC_POS_INIT = "\e@"

    ESC_POS_LEFT = "\ea\0"
    ESC_POS_CENTER = "\ea\1"
    ESC_POS_RIGHT = "\ea\2"

    ESC_POS_CP_1252 = "\et\x10"

    ESC_POS_FONT_A = "\eM\0"
    ESC_POS_FONT_B = "\eM\1"

    ESC_POS_EMPH = "\eE\1"
    ESC_POS_NORM = "\eE\0"

    ESC_POS_CUT = "\x1dVA\0"

  end
end
