# frozen_string_literal: true

module ActiveJobject
  module Parser
    class InvalidInstance < ActiveJobject::Error; end

    def parse(klass, **attributes)
      raise InvalidInstance, "Class #{klass&.name || klass} is not an instance." if klass.is_a?(Class)

      attributes.each do |attribute, value|
        return_value = if value.is_a?(Array)
          parse_array(klass, attribute, value)
        elsif value.is_a?(Hash)
          parse_hash(klass, attribute, value)
        else
          value
        end

        define_singleton_methods(klass, attribute, return_value)
      end

      klass
    end

    private

    def parse_array(klass, attribute, value)
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
    end

    def parse_hash(klass, attribute, value)
      subklass = define_const(klass.class, attribute.split('_').map(&:capitalize).join.to_sym, Class.new(klass.class))
      subklass_instance = subklass.new

      parse(subklass_instance, **value)
    end

    def define_singleton_methods(klass, attribute, return_value)
      klass.instance_variable_set(:"@#{attribute}", return_value)

      klass.singleton_class.send(:define_method, attribute.to_sym) do
        klass.instance_variable_get(:"@#{attribute}")
      end

      klass.singleton_class.send(:define_method, "#{attribute.to_sym}=") do |new_value|
        instance_variable_set(:"@#{attribute}", new_value)
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
end
