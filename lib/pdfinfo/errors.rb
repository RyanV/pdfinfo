class Pdfinfo
  class PdfinfoError < ::StandardError
  end

  class CommandNotFound < PdfinfoError
    def initialize(command)
      super("Command Not Found - '#{command}'")
    end
  end
end