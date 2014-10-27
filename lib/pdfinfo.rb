require 'open3'
require 'shellwords'

class Pdfinfo
  DIMENSIONS_REGEXP = /([\d\.]+) x ([\d\.]+)/

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
    flags = []
    flags += ['-opw', opts[:owner_password]] if opts[:owner_password]
    flags += ['-upw', opts[:user_password]] if opts[:user_password]

    command = Shellwords.join([pdfinfo_command, *flags, file_path])
    stdout, status = Open3.capture2(command)
    stdout.chomp
  end

  def self.pdfinfo_command
    @pdfinfo_command || 'pdfinfo'
  end

  def self.pdfinfo_command=(cmd)
    @pdfinfo_command = cmd
  end

  def initialize(source_path, opts = {})
    info_hash = parse_shell_response(Pdfinfo.exec(source_path, opts))

    @title          = info_hash['Title'].empty? ? nil : info_hash['Title']
    @subject        = info_hash['Subject'].empty? ? nil : info_hash['Subject']
    @keywords       = info_hash['Keywords'].empty? ? [] : info_hash['Keywords'].split(/\s/)
    @author         = info_hash['Author'].empty? ? nil : info_hash['Author']
    @creator        = info_hash['Creator'].empty? ? nil : info_hash['Creator']
    @producer       = info_hash['Producer'].empty? ? nil : info_hash['Producer']
    @creation_date  = info_hash['CreationDate'].empty? ? nil : Time.parse(info_hash['CreationDate'])
    @tagged         = !!(info_hash['Tagged'] =~ /yes/)
    @form           = info_hash['Form']
    @page_count     = info_hash['Pages'].to_i
    @encrypted      = !!(info_hash['Encrypted'] =~ /yes/)

    raw_usage_rights = Hash[info_hash['Encrypted'].scan(/(\w+):(\w+)/)]
    booleanize_usage_right = lambda {|val| !(raw_usage_rights[val] == 'no') }

    @usage_rights = {}.tap do |ur|
      ur[:print]     = booleanize_usage_right.call('print')
      ur[:copy]      = booleanize_usage_right.call('copy')
      ur[:change]    = booleanize_usage_right.call('change')
      ur[:add_notes] = booleanize_usage_right.call('addNotes')
    end

    @width, @height = extract_page_dimensions(info_hash['Page size'])
    @file_size      = info_hash['File size'].to_i
    @pdf_version    = info_hash['PDF version']
  end

  def tagged?
    @tagged
  end

  def encrypted?
    @encrypted
  end

  def printable?
    @usage_rights[:print]
  end

  def copyable?
    @usage_rights[:copy]
  end

  def changeable?
    @usage_rights[:change]
  end
  alias modifiable? changeable?

  def annotatable?
    @usage_rights[:add_notes]
  end

  private
  def parse_shell_response(response_str)
    Hash[response_str.split(/\n/).map {|kv| kv.split(/:/, 2).map(&:strip) }]
  end

  def extract_page_dimensions(str)
    return unless str
    str.match(DIMENSIONS_REGEXP).captures.map(&:to_f)
  end
end