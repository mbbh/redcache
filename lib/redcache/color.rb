module RedCache
   module Color
    def colorize(text, color_code)
      "#{color_code}#{text}\e[0m"
    end

    def red(text); colorize(text, "\e[31m"); end
    def green(text); colorize(text, "\e[32m"); end
    def blue(text); colorize(text, "\e[34m"); end
  end
end