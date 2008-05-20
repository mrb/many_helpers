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
              self.#{first.to_s}_#{second.to_s.pluralize}.each do |fs|
                unless hash_or_values.keys.include?(fs.id.to_s)
                  hash_or_values.delete(fs.id.to_s)
                  fs.destroy
                end
              end
              self.#{first.to_s}_#{second.to_s.pluralize}.update(hash_or_values.keys, hash_or_values.values)
            when Array
              self.#{first.to_s}_#{second.to_s.pluralize}_association = hash_or_values
            end
          end
          
          #setter method for new #{first.to_s}_#{second.to_s.pluralize}
          def new_#{first.to_s}_#{second.to_s.pluralize}=(abs)
            @#{first.to_s}#{second.to_s.pluralize} = []
            abs.each do |ab|
              @#{first.to_s}#{second.to_s.pluralize} << #{association_name.to_s.camelize}.new(ab[0]=>ab[1], (self.class.name.downcase+"_id").to_sym =>self.id)
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