require 'money'

class ActiveRecord::Base
  class << self
    def acts_as_money
      include(ActsAsMoney)
    end
  end
end


module ActsAsMoney #:nodoc:
  def self.included(base) #:nodoc:
    base.extend ClassMethods
  end

  module ClassMethods
    def money(name, options = {})
      composed_of name,  {
        :class_name => 'Money',
        :allow_nil => options[:allow_nil],
        :mapping => [
          [(options[:cents] || :cents).to_s, 'cents'],
          [(options[:currency] || :currency).to_s, 'currency_as_string']
        ],
        :constructor => lambda {|cents, currency| options[:allow_nil] && !cents ? nil : Money.new(cents || 0, currency || Money.default_currency)},
        :converter => lambda {  |value|
          case value
          when Fixnum, Float
            Money.new((value * 100.0).to_d, Money.default_currency)
          when String
            Money.new((value.to_f * 100).to_d, Money.default_currency)
          else
            value
          end
        }
      }      
    end
  end
end



