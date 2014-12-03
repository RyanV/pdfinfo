require 'open3'
require 'shellwords'
require 'pdfinfo/errors'

class Pdfinfo
  DIMENSIONS_REGEXP = /([\d\.]+) x ([\d\.]+)/

  attr_reader :title, :subject, :keywords, :author, :creator,
    :creation_date, :modified_date, :usage_rights, :producer,
    :form, :page_count, :width, :height, :file_size, :pdf_version

  class << self
    def pdfinfo_command
      @pdfinfo_command || 'pdfinfo'
    end

    def pdfinfo_command=(cmd)
      @pdfinfo_command = cmd
    end

    def pdfinfo_command?
      system("type #{pdfinfo_command} >/dev/null 2>&1")
    end

    attr_accessor :config_path
  end

  def initialize(source_path, opts = {})
    info_hash = parse_shell_response(exec(source_path, opts))

    @title          = presence(info_hash['Title'])
    @subject        = presence(info_hash['Subject'])
    @author         = presence(info_hash['Author'])
    @creator        = presence(info_hash['Creator'])
    @producer       = presence(info_hash['Producer'])
    @tagged         = !!(info_hash['Tagged'] =~ /yes/)
    @encrypted      = !!(info_hash['Encrypted'] =~ /yes/)
    @page_count     = info_hash['Pages'].to_i
    @file_size      = info_hash['File size'].to_i
    @form           = info_hash['Form']
    @pdf_version    = info_hash['PDF version']

    @keywords       = (info_hash['Keywords'] || '').split(/\s/)
    @creation_date  = parse_time(info_hash['CreationDate'])
    @modified_date  = parse_time(info_hash['ModDate'])

    raw_usage_rights = Hash[info_hash['Encrypted'].scan(/(\w+):(\w+)/)]
    booleanize_usage_right = lambda {|val| !(raw_usage_rights[val] == 'no') }

    @usage_rights = {}.tap do |ur|
      ur[:print]     = booleanize_usage_right.call('print')
      ur[:copy]      = booleanize_usage_right.call('copy')
      ur[:change]    = booleanize_usage_right.call('change')
      ur[:add_notes] = booleanize_usage_right.call('addNotes')
    end

    @width, @height = extract_page_dimensions(info_hash['Page size'])
  end

  def tagged?
    @tagged
  end

  def encrypted?
    @encrypted
  end

  %w(print copy change).each do |ur|
    define_method("#{ur}able?") { @usage_rights[ur.to_sym] }
  end
  alias modifiable? changeable?

  def annotatable?
    @usage_rights[:add_notes]
  end

  def to_hash
    instance_variables.inject({}) {|h, var| h[var[1..-1].to_sym] = instance_variable_get(var); h }
  end

  private
  # executes pdfinfo command with supplied options
  # @param [String,Pathname] file_path
  # @param [Hash] opts
  # @return [String] output
  def exec(file_path, opts = {})
    validate_pdfinfo_command!

    flags = build_options(opts)

    command = [self.class.pdfinfo_command, *flags, file_path.to_s].shelljoin

    stdout, status = Open3.capture2(command)
    force_utf8_encoding(stdout)
  end

  # prepares array of flags to pass as command line options
  # ---
  # @todo: add option builder class
  # +++
  # @param [Hash] opts of options
  # @option opts [String] :encoding ('UTF-8')
  # @option opts [String] :owner_password
  # @option opts [String] :user_password
  # @return [Array<String>] array of flags
  def build_options(opts = {})
    flags = []
    flags.concat(['-enc', opts.fetch(:encoding, 'UTF-8')])
    flags.concat(['-opw', opts[:owner_password]]) if opts[:owner_password]
    flags.concat(['-upw', opts[:user_password]]) if opts[:user_password]
    xpdfrc_path = opts[:config_path] || self.class.config_path
    flags.concat(['-cfg', xpdfrc_path]) if xpdfrc_path
    flags
  end

  # @param [String] str
  # @return [String] UTF-8 encoded string
  def force_utf8_encoding(str)
    str = str.encode(Encoding::UTF_16, invalid: :replace, undef: :replace, replace: '')
    str.encode!(Encoding::UTF_8)
  end

  def presence(val)
    (val.nil? || val.empty? ) ? nil : val
  end

  def parse_shell_response(response_str)
    Hash[response_str.split(/\n/).map {|kv| kv.split(/:/, 2).map(&:strip) }]
  end

  def extract_page_dimensions(str)
    return unless str
    str.match(DIMENSIONS_REGEXP).captures.map(&:to_f)
  end

  def parse_time(str)
    return unless presence(str)
    DateTime.strptime(str, '%a %b %e %H:%M:%S %Y')
  rescue ArgumentError => e
    nil
  end

  def validate_pdfinfo_command!
    unless self.class.pdfinfo_command?
      raise CommandNotFound, self.class.pdfinfo_command
    end
  end
end