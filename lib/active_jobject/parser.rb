module ActiveJobject::Parser
  class InvalidInstance < ActiveJobject::Error; end

  def parse(klass, **attributes)
    raise InvalidInstance.new("Class #{klass&.name || klass} is not an instance.") if klass.is_a?(Class)

    attributes.each do |attribute, value|
      return_value = if value.is_a?(Array)
        subklass = define_const(klass.class, attribute.split('_').map(&:capitalize).join.to_sym, Class.new(klass.class))

        ActiveJobject::Collection.new(
          value.map do |arr_value|
            if arr_value.is_a?(Hash)
              subklass_instance = subklass.new
              parse(subklass_instance, **arr_value)
            else
              arr_value
            end
          end
        )
      elsif value.is_a?(Hash) && attribute != 'permissions'
        subklass = define_const(klass.class, attribute.split('_').map(&:capitalize).join.to_sym, Class.new(klass.class))
        subklass_instance = subklass.new

        parse(subklass_instance, **value)
      else
        value
      end

      self.define_singleton_methods(klass, attribute, return_value)
    end

    klass
  end

  private

  def define_singleton_methods(klass, attribute, return_value)
    klass.instance_variable_set("@#{attribute}".to_sym, return_value)

    klass.singleton_class.send(:define_method, attribute.to_sym) do
      klass.instance_variable_get("@#{attribute}".to_sym)
    end

    klass.singleton_class.send(:define_method, "#{attribute.to_sym}=") do |new_value|
      instance_variable_set("@#{attribute}".to_sym, new_value)
    end
  end

  def define_const(base_klass, name, klass)
    if base_klass.const_defined?(name, false)
      base_klass.const_get(name, false)
    else
      base_klass.const_set(name, klass)
    end
  end
end
