class Pdfinfo
  class Page
    include ObjectToHash
    MATCHER = /(?<=\s)(\d+(?:\.\d+)?)(?=\s)/

    attr_reader :page_number, :width, :height, :rotation

    def self.from_string(string)
      new *string.scan(MATCHER).flatten
    end

    def initialize(page_number, width, height, rotation)
      @page_number = page_number.to_i
      @width       = width.to_f
      @height      = height.to_f
      @rotation    = rotation.to_f
    end

    def rotated?
      0 != @rotation
    end
  end
end