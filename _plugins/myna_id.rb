# Converts a string to a string suitable for use in an HTML attribute
#
# Replaces / with -
module Jekyll
  module MynaId
    def myna_id(input)
      input.gsub(%r{[/-]}, '')
    end
  end
end

Liquid::Template.register_filter(Jekyll::MynaId)
