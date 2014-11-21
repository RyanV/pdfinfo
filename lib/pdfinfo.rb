require 'open3'
require 'shellwords'

class Pdfinfo
  DIMENSIONS_REGEXP = /([\d\.]+) x ([\d\.]+)/

  class PdfinfoError < ::StandardError
  end

  class CommandNotFound < PdfinfoError
    def initialize(command)
      super("Command Not Found - '#{command}'")
    end
  end


  attr_reader :title,
    :subject,
    :keywords,
    :author,
    :creator,
    :creation_date,
    :usage_rights,
    :producer,
    :form,
    :page_count,
    :width,
    :height,
    :file_size,
    :pdf_version

  def self.exec(file_path, opts = {})
    raise CommandNotFound, 'pdfinfo' unless pdfinfo_command?
    flags = []
    flags.concat(['-enc', opts.fetch(:encoding, 'UTF-8')])
    flags.concat(['-opw', opts[:owner_password]]) if opts[:owner_password]
    flags.concat(['-upw', opts[:user_password]]) if opts[:user_password]

    command = Shellwords.join([pdfinfo_command, *flags, file_path])
    stdout, status = Open3.capture2(command)
    stdout.encode('UTF-8', invalid: :replace, replace: '')
  end

  def self.pdfinfo_command
    @pdfinfo_command || 'pdfinfo'
  end

  def self.pdfinfo_command=(cmd)
    @pdfinfo_command = cmd
  end

  def self.pdfinfo_command?
    system("type #{pdfinfo_command} >/dev/null 2>&1")
  end

  def initialize(source_path, opts = {})
    info_hash = parse_shell_response(Pdfinfo.exec(source_path, opts))

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

    @keywords       = (info_hash['Keywords'] || "").split(/\s/)
    @creation_date  = presence(info_hash['CreationDate']) ? Time.parse(info_hash['CreationDate']) : nil

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

  private
  def presence(val)
    (val.nil? || val.empty?) ? nil : val
  end

  def parse_shell_response(response_str)
    Hash[response_str.split(/\n/).map {|kv| kv.split(/:/, 2).map(&:strip) }]
  end

  def extract_page_dimensions(str)
    return unless str
    str.match(DIMENSIONS_REGEXP).captures.map(&:to_f)
  end
end