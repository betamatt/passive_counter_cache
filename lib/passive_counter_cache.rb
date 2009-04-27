class PassiveCounterCache
  @@caches = []
  
  class << self
    def register_association_cache(klass, association, column_name)
      @@caches << [klass, association, column_name]
    end
  
    def update_all_caches!
      @@caches.each do |cache|
        update_association_cache(*cache)
      end
      nil
    end
  
    def update_association_cache(klass, association, column_name)    
      reflection = klass.reflect_on_association(association)

      sql = "UPDATE `#{reflection.klass.table_name}`, (" +
              "SELECT id, COUNT(*) as `count` FROM `#{klass.table_name}` GROUP BY `#{reflection.primary_key_name}`" +
            ") counter_values " +
            "SET `#{column_name}` = counter_values.`count` " +
            "WHERE counter_values.id = `#{reflection.klass.table_name}`.`#{reflection.klass.primary_key}`"
      
      klass.connection.update(sql, "Passive Counter Cache Update")
    end
  end
end
