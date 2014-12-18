class Array
  def to_h
    map {|v| v.respond_to?(:to_h) ? v.to_h : v }
  end unless method_defined?(:to_h)
end

class Pdfinfo
  module ObjectToHash
    def to_h
      instance_variables.inject({}) do |hash, var|
        val = instance_variable_get(var)
        hash[var[1..-1].to_sym] = (val.respond_to?(:to_h) ? val.to_h : val)
        hash
      end
    end
    alias to_hash to_h
    alias as_json to_h
  end
end