class Pdfinfo
  class PdfinfoError < ::StandardError
  end

  class CommandFailed < PdfinfoError
  end

  class CommandNotFound < PdfinfoError
    def initialize(command)
      super("Command Not Found - '#{command}'")
    end
  end
end