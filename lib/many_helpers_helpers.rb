module ManyHelpersHelpers
  
  def add_many_link(linktext, associated_model, association_model, othershit) 
    link_to_function linktext do |page| 
       eval("page.insert_html :bottom, :#{associated_model.to_s}, :partial => '#{associated_model.to_s}', :object => #{association_model.to_s}.new") 
    end
  end

end