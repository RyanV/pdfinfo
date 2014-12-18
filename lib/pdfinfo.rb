require 'open3'
require 'shellwords'
require 'date'
require 'time'
%w(object_to_hash errors page).each {|f| require File.expand_path("../pdfinfo/#{f}", __FILE__)}

class Pdfinfo
  include ObjectToHash

  attr_reader :pages, :title, :subject, :keywords, :author, :creator,
    :creation_date, :modified_date, :usage_rights, :producer,
    :form, :page_count, :width, :height, :file_size, :pdf_version

  class << self
    def pdfinfo_command
      @pdfinfo_command || 'pdfinfo'
    end

    def pdfinfo_command=(cmd)
      @pdfinfo_command = cmd
    end

    # @return [Boolean]
    def pdfinfo_command?
      system("type #{pdfinfo_command} >/dev/null 2>&1")
    end

    attr_accessor :config_path
  end

  def initialize(source_path, opts = {})
    @pages = []

    info_hash = parse_shell_response(exec(source_path, opts))

    info_hash.delete_if do |key, value|
      @pages << Page.from_string(value) if key.match(/Page\s+\d+\ssize/)
    end

    encrypted_val = info_hash.delete('Encrypted')

    @title          = presence(info_hash.delete('Title'))
    @subject        = presence(info_hash.delete('Subject'))
    @author         = presence(info_hash.delete('Author'))
    @creator        = presence(info_hash.delete('Creator'))
    @producer       = presence(info_hash.delete('Producer'))
    @tagged         = !!(info_hash.delete('Tagged') =~ /yes/)
    @encrypted      = !!(encrypted_val =~ /yes/)
    @page_count     = info_hash.delete('Pages').to_i
    @file_size      = info_hash.delete('File size').to_i
    @form           = info_hash.delete('Form')
    @pdf_version    = info_hash.delete('PDF version')
    @optimized      = !!(info_hash.delete('Optimized') =~ /yes/)
    @keywords       = (info_hash.delete('Keywords') || '').split(/\s/)
    @creation_date  = parse_time(info_hash.delete('CreationDate'))
    @modified_date  = parse_time(info_hash.delete('ModDate'))

    raw_usage_rights = Hash[encrypted_val.scan(/(\w+):(\w+)/)]
    booleanize_usage_right = lambda {|val| raw_usage_rights[val] != 'no' }

    @usage_rights = {}.tap do |ur|
      ur[:print]     = booleanize_usage_right.call('print')
      ur[:copy]      = booleanize_usage_right.call('copy')
      ur[:change]    = booleanize_usage_right.call('change')
      ur[:add_notes] = booleanize_usage_right.call('addNotes')
    end

    # temporarily continue setting #width and #height on Pdfinfo object
    # to maintain legacy behavior
    @width  = @pages[0].width
    @height = @pages[0].height
  end

  # @return [Boolean]
  def tagged?
    @tagged
  end

  # @return [Boolean]
  def encrypted?
    @encrypted
  end

  # @return [Boolean]
  def optimized?
    @optimized
  end

  %w(print copy change).each do |ur|
    # @return [Boolean]
    define_method("#{ur}able?") { @usage_rights[ur.to_sym] }
  end
  alias modifiable? changeable?

  # @return [Boolean]
  def annotatable?
    @usage_rights[:add_notes]
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
    xpdfrc_path = opts.fetch(:config_path, self.class.config_path)

    # these flag will always be part of the cli options. Values have defaults and can be overridden
    flags.concat(['-f',   opts.fetch(:first_page, 0)])
    flags.concat(['-l',   opts.fetch(:last_page, -1)])
    flags.concat(['-enc', opts.fetch(:encoding, Encoding::UTF_8)])
    # optional flags.  if no value, the flag wont be added
    flags.concat(['-cfg', xpdfrc_path])           if xpdfrc_path
    flags.concat(['-opw', opts[:owner_password]]) if opts[:owner_password]
    flags.concat(['-upw', opts[:user_password]])  if opts[:user_password]
    flags.map(&:to_s)
  end

  # @param [String] str
  # @return [String] UTF-8 encoded string
  def force_utf8_encoding(str)
    return str if str.valid_encoding?
    str = str.encode(Encoding::UTF_16, invalid: :replace, undef: :replace, replace: '')
    str.encode!(Encoding::UTF_8)
  end

  def presence(val)
    (val.nil? || val.empty? ) ? nil : val
  end

  def parse_shell_response(response_str)
    Hash[response_str.split(/\n/).map {|kv| kv.split(/:/, 2).map(&:strip) }]
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