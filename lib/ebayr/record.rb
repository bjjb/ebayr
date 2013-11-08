# -*- encoding : utf-8 -*-
module Ebayr
  class Record < Hash
    def initialize(initial = {})
      super()
      initial.each { |k, v| self[k] = v }
    end

    def <=>(another)
      return false unless another.respond_to(:keys) and another.respond_to(:"[]")
      another.keys.each do |k|
        return false unless convert_value(another[k]) == self[k]
      end
      true
    end

    def [](key)
      super(convert_key(key))
    end

    def []=(key, value)
      key = convert_key(key)
      value = convert_value(value)
      (class << self; self; end).send(:define_method, key) { value }
      super(key, value)
    end

    def has_key?(key)
      super(convert_key(key))
    end

  protected
    def convert_key(k)
      self.class.convert_key(k)
    end

    def self.convert_key(k)
      k.to_s.underscore.gsub(/e_bay/, "ebay").to_sym
    end

    def convert_value(arg)
      self.class.convert_value(arg)
    end

    def self.convert_value(arg)
      case arg
        when Hash then Record.new(arg)
        when Array then arg.map { |a| convert_value(a) }
        else arg
      end
    end
  end
end
