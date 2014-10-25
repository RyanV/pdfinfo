require 'open3'
require 'pathname'

class Pdfinfo
  DIMENSIONS_REGEXP = /(\d+) x (\d+)/

  attr_reader :creator,
    :producer,
    :form,
    :page_count,
    :width,
    :height,
    :file_size,
    :pdf_version

  def self.exec(file_path)
    stdout, stderr, status = Open3.capture2e("pdfinfo #{file_path}")
    stdout.chomp
  end

  def self.pdfinfo_command
    @pdfinfo_command || 'pdfinfo'
  end

  def self.pdfinfo_command=(cmd)
    @pdfinfo_command = cmd
  end

  def initialize(source_path)
    info_hash = parse_shell_response(exec(source_path))

    @creator        = info_hash['Creator']
    @producer       = info_hash['Producer']
    @tagged         = !!(info_hash['Tagged'] =~ /yes/)
    @form           = info_hash['Form']
    @page_count     = info_hash['Pages'].to_i
    @encrypted      = !!(info_hash['Encrypted'] =~ /yes/)
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

  private

  def exec(file_path)
    self.class.exec(file_path)
  end

  def parse_shell_response(response_str)
    Hash[response_str.split(/\n/).map {|kv| kv.split(/:\s+/) }]
  end

  def extract_page_dimensions(str)
    return unless str
    str.match(DIMENSIONS_REGEXP).captures.map(&:to_i)
  end
end