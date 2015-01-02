require File.expand_path("../to_hash", __FILE__)

class Pdfinfo
  class Page
    include Pdfinfo::ToHash
    MATCHER = /(?<=\s)?(\d+(?:\.\d+)?)(?=\s)/

    attr_reader :width, :height, :rotation

    def self.from_string(string)
      new *string.scan(MATCHER).flatten
    end

    def initialize(width, height, rotation = 0.0)
      @width       = width.to_f
      @height      = height.to_f
      @rotation    = rotation.to_f
    end

    def rotated?
      0 != @rotation
    end
  end
end