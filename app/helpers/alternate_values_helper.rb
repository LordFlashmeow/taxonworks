module AlternateValuesHelper

  def link_to_remove_alternate_value(link_text, f)
    f.hidden_field(:_destroy) + link_to(link_text, '', id: 'alternate-value-remove')
  end

  def link_to_add_alternate_value(link_text, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields     = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("#{associtaion}/form", :f => builder)
    end
    # link_to(link_text, '', id: "#{association[0]}-add", onclick: "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")")
    # link_to(link_text, '', id: "#{association[0]}-add")
    # link_to(link_text, '', id: "#{association[0]}-add", fields: fields)
    link_to(link_text, '', id: "#{association}-add", content: "#{fields}")

  end

end
