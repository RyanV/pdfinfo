class Pdfinfo
  module ToHash
    def to_hash
      instance_variables.inject({}) { |h, var| h[var[1..-1].to_sym] = instance_variable_get(var); h }
    end
  end
end