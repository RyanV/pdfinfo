# Helper class for modifying pdfinfo stdout in tests.
class Pdfinfo::ResponseModifier
  attr_reader :response, :raw_response
  alias_method :to_s, :response

  DEFAULT_USAGE_RIGHTS = {
    print: false,
    copy: false,
    change: false,
    addNotes: false
  }.freeze

  # @param [String] response raw response from pdfinfo stdout
  def initialize(response)
    @raw_response = response.freeze
    @response = response.dup
  end

  # Deletes the entire line identified by the given key
  #
  # @param [String] key
  # @api public
  def delete(key)
    old_line = get_line(key)
    new_line = ''
    update_response_line!(old_line, new_line)
  end

  # Sets a new value for the given key.
  # @param [String] key
  # @param [String] value
  # @api public
  def set(key, value)
    old_line = get_line(key)
    new_line = replace_line_value(old_line, value)
    update_response_line!(old_line, new_line)
  end

  # builds encryption usage rights string and sets it for the key 'Encrypted:'
  #
  # @param [Boolean] is_encrypted
  # @param [Hash{Symbol => Boolean}] opts a hash of usage rights
  #   @option :print
  #   @option :copy
  #   @option :change
  #   @option :addNotes
  # @api public
  def set_encryption(is_encrypted, opts = {})
    usage_rights = usage_rights_to_str(opts)
    set('Encrypted', "#{bool_to_str(is_encrypted)} (#{usage_rights})")
  end

  private
  # @param [Hash{Symbol => Boolean}] opts a hash of usage rights
  # @return [String] stringified usage rights formatted
  # @api private
  def usage_rights_to_str(opts)
    DEFAULT_USAGE_RIGHTS.merge(opts).map { |k, v| [k, bool_to_str(v)].join(":") }.join(" ")
  end


  # @param [Boolean] bool
  # @return [String]
  # @api private
  def bool_to_str(bool)
    bool ? 'yes' : 'no'
  end

  # @param [String] line a single line from the output (includes newline)
  # @param [String] val the string replacement
  # @return [String] line with replaced value. maintains whitespace-ing
  # @api private
  def replace_line_value(line, val)
    line.sub(/(?<=:)([[:space:]]+)(.+)$/, "\\1#{val}")
  end

  # @param [String] key
  # @return [String] a line
  # @api private
  def get_line(key)
    @response[/^#{Regexp.escape(key)}.+\n/]
  end

  # @param [String] old_line
  # @param [String] new_line
  # @return [String] response string
  # @api private
  def update_response_line!(old_line, new_line)
    @response = @response.sub(Regexp.new(Regexp.escape(old_line)), new_line)
  end
end