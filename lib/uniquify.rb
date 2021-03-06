module Uniquify
  def self.included(base)
    base.extend ClassMethods
  end

  def ensure_unique(name)
    begin
      self[name] = yield
    end while self.class.exists?(name => self[name])
  end

  def generate_unique(name, options = {}, &block)
    options = self.class.default_uniquify_options.merge(options)

    if block
      ensure_unique(name, &block)
    else
      ensure_unique(name) do
        Array.new(options[:length]) { options[:chars].to_a[rand(options[:chars].to_a.size)] }.join
      end
    end
  end


  module ClassMethods

    def default_uniquify_options
      {
        :length => 8,
        :chars => ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
      }
    end

    def uniquify(*args, &block)
      options = args.pop if args.last.kind_of? Hash
      args.each do |name|
        before_validation :on => :create do
          generate_unique(name, options, &block)
        end
      end
    end

  end
end

class ActiveRecord::Base
  include Uniquify
end
