require 'passive_counter_cache'

ActiveRecord::Base.class_eval do
  class << self
    def belongs_to_with_passive_counter_cache(name, opts = {}, &block)
      if opts.delete(:passive_counter_cache)
        PassiveCounterCache.register_association_cache self, name, opts[:counter_cache] || "#{name.to_s}_count"
        opts[:counter_cache] = false
      end
      
      belongs_to_without_passive_counter_cache(name, opts, &block)
    end

    alias_method_chain :belongs_to, :passive_counter_cache
  end
end