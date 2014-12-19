class Pdfinfo
  module ObjectToHash
    def as_json
      instance_variables.inject({}) do |hash, var|
        val = instance_variable_get(var)
        hash[var[1..-1].to_sym] = (val.respond_to?(:as_json) ? val.as_json : val)
        hash
      end
    end
    alias to_hash as_json
    alias to_h as_json
  end
end

class Array
  def as_json
    map {|v| v.respond_to?(:as_json) ? v.as_json : v }
  end unless method_defined?(:as_json)
end