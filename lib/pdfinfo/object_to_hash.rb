class Pdfinfo
  module ObjectToHash
    def to_hash
      instance_variables.inject({}) do |h, var|
        h[var[1..-1].to_sym] = instance_variable_get(var); h
      end
    end
    alias as_json to_hash
    alias to_h to_hash
  end
end