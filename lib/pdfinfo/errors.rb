class Pdfinfo
  class PdfinfoError < ::StandardError
  end

  class CommandFailed < PdfinfoError
    attr_reader :command, :error

    def initialize(command:, error: nil)
      super(command)
      @command = command
      @error = error
    end
  end

  class CommandNotFound < PdfinfoError
    def initialize(command)
      super("Command Not Found - '#{command}'")
    end
  end
end