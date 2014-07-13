module Meteo
  module Lib
    class Bitmap
      def initialize(chars, width, height)
        @chars, @width, @height  = chars, width, height
      end

      def bit(x, y)
        if x < @width && y < @height
          bitnum = (x + y * @width)

          char = @chars[bitnum / 8] || 0

          (char >> (7 - bitnum % 8)) & 1
        else
          0
        end
      end

      def setbit(x, y)
        if x < @width && y < @height
          bitnum = (x + y * @width)

          char = @chars[bitnum / 8] || 0

          char |= 1 << (7 - bitnum % 8)

          @chars[bitnum / 8] = char
        end
      end

      def subimage(x1, y1, x2, y2)
        new_bitmap = Bitmap.new(Array.new(((x2 - x1) * (y2 - y1) + 7) / 8, 0), x2 - x1, y2 - y1)
        (y1...y2).each do |y|
          (x1...x2).each do |x|
            if bit(x, y) == 1
              new_bitmap.setbit(x - x1, y - y1)
            end
          end
        end

        new_bitmap
      end

      def print_bitmap
        bits = @chars.pack("C*")
        var_length = bits.length + 10

        out = [
          "\x1d(L",
          var_length%256,
          var_length/256,
          48,
          112,
          48,
          1,
          1,
          49,
          @width%256,
          @width/256,
          @height%256,
          @height/256,
          bits
        ].pack("A*C12A*")

        out += [
          "\x1d(L",
          2,
          0,
          48,
          50
        ].pack("A*C4")

        out
      end
    end
  end
end
