class PSD
  class Color
    class_eval do
      def color_space_to_argb(color_space, color_component)
        case color_space
        when 0
          rgb_to_color *color_component
        when 1
          hsb_to_color color_component[0], 
            color_component[1] / 100.0, color_component[2] / 100.0
        when 2
          cmyk_to_color color_component[0] / 100.0,
            color_component[1] / 100.0, color_component[2] / 100.0,
            color_component[3] / 100.0
        when 7
          lab_to_color *color_component
        else
          0x00FFFFFF
        end
      end

      def rgb_to_color(*args)
        argb_to_color(255, *args)
      end

      def argb_to_color(a, r, g, b)
        (a << 24) | (r << 16) | (g << 8) | b
      end

      def hsb_to_color(*args)
        ahsb_to_color(255, *args)
      end

      def ahsb_to_color(alpha, hue, saturation, brightness)
        if saturation == 0
          b = g = r = 255 * brightness
        else
          if brightness <= 0.5
            m2 = brightness * (1 + saturation)
          else
            m2 = brightness + saturation - brightness * saturation
          end

          m1 = 2 * brightness - m2
          r = hue_to_color(hue + 120, m1, m2)
          g = hue_to_color(hue, m1, m2)
          b = hue_to_color(hue - 120, m1, m2)
        end

        argb_to_color alpha, r, g, b
      end

      def hue_to_color(hue, m1, m2)
        hue = hue % 360
        if hue < 60
          v = m1 + (m2 - m1) * hue / 60
        elsif hue < 180
          v = m2
        elsif hue < 240
          v = m1 + (m2 - m1) * (240 - hue) / 60
        else
          v = m1
        end

        v * 255
      end

      def cmyk_to_color(c, m, y, k)
        r = 1 - (c * (1 - k) + k) * 255
        g = 1 - (m * (1 - k) + k) * 255
        b = 1 - (y * (1 - k) + k) * 255

        r = [0, r, 255].sort[1]
        g = [0, g, 255].sort[1]
        b = [0, b, 255].sort[1]

        rgb_to_color r, g, b
      end

      def lab_to_color(*args)
        alab_to_color(255, *args)
      end

      def alab_to_color(alpha, l, a, b)
        xyz = lab_to_xyz(l, a, b)
        axyz_to_color alpha, xyz[:x], xyz[:y], xyz[:z]
      end

      def lab_to_xyz(l, a, b)
        y = (l + 16) / 116
        x = y + (a / 500)
        z = y - (b / 200)

        x, y, z = [x, y, z].map do |n|
          n**3 > 0.008856 ? n**3 : (n - 16 / 116) / 7.787
        end
      end
    end
  end
end