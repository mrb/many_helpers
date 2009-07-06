#author, book
#first.to_s, second.to_s
module ManyHelpers
  def many_helpers(*association_names)
    #pass this :author_books, or :book_genres, etc.
    association_names.each do |association_name|
      return unless association_name.is_a?(Symbol) && association_name.to_s.include?('_')
        a_n = [association_name.to_s.split('_')[0], association_name.to_s.split('_')[1]]
        a_n.inject{|a,b| {a=>b}}.each_pair{ |first, second|
        #here you have author, book
        module_eval <<-END
          alias :#{first.to_s}_#{second.to_s.pluralize}_association= :#{first.to_s}_#{second.to_s.pluralize}=
          def #{first.to_s}_#{second.to_s.pluralize}=(hash_or_values)
            return unless hash_or_values
            case hash_or_values
            when Hash
              #self.#{first.to_s}_#{second.to_s.pluralize}.each do |fs|
              #  unless hash_or_values.keys.include?(fs.id.to_s)
              #    hash_or_values.delete(fs.id.to_s)
              #    #fs.destroy
              #  end
              #end
              self.#{first.to_s}_#{second.to_s.pluralize}.update(hash_or_values.keys, hash_or_values.values)                
            when Array
              self.#{first.to_s}_#{second.to_s.pluralize}_association = hash_or_values
            end
          end
          
          def auto_#{first.to_s}_#{second.to_s.pluralize}=(hash_or_values)
            return unless hash_or_values
            case hash_or_values
            when Hash
              self.#{first.to_s}_#{second.to_s.pluralize}.each do |fs|
              unless hash_or_values.keys.include?(fs.id.to_s)
                hash_or_values.delete(fs.id.to_s)
                fs.destroy
              end
             end
             
             asoc = hash_or_values.values[0].keys[0].split("_")[0].capitalize.constantize
             a = {hash_or_values.values[0].keys[0] => asoc.find_by_name(hash_or_values.values[0].values[0]).id}
             self.#{first.to_s}_#{second.to_s.pluralize}.update(hash_or_values.keys, [a])
             
            when Array
              self.#{first.to_s}_#{second.to_s.pluralize}_association = hash_or_values
            end
          end
          
          #setter method for new #{first.to_s}_#{second.to_s.pluralize} with autocomplete
          def new_autocomplete_#{first.to_s}_#{second.to_s.pluralize}=(nac)
            @#{first.to_s}#{second.to_s.pluralize} = []
            nac.each do |na|
              self.save
              unless eval(na[0].split("_")[0].capitalize).find_by_name(na[1]).nil?
                @#{first.to_s}#{second.to_s.pluralize} << #{association_name.to_s.camelize}.new(na[0] => eval(na[0].split("_")[0].capitalize).find_by_name(na[1]).id, (self.class.name.downcase+"_id").to_sym =>self.id)
              end
            end
          end
          
          #setter method for new #{first.to_s}_#{second.to_s.pluralize}
          def new_#{first.to_s}_#{second.to_s.pluralize}=(abs)
            return unless abs && abs.respond_to?(:each)
            @#{first.to_s}#{second.to_s.pluralize} = []
            self.save
            abs.each do |ab|
              ab[(self.class.name.downcase+"_id").to_sym] = self.id
              @#{first.to_s}#{second.to_s.pluralize} << #{association_name.to_s.camelize}.new(ab)
            end
          end
          
          #after_save
          def #{first.to_s}#{second.to_s}
            
            return unless @#{first.to_s}#{second.to_s.pluralize}
            @#{first.to_s}#{second.to_s.pluralize}.each do |t|
              t.save
            end
          end
          
          after_save :#{first.to_s}#{second.to_s}
          
        END
      }
    end
  end  
end