require 'spec_helper'

<% output_attributes = attributes.reject{|attribute| [:datetime, :timestamp, :time, :date].index(attribute.type) } -%>
describe "/<%= plural_web_path %>/edit.<%= default_file_extension %>" do
  include <%= controller_class_name %>Helper

  before(:each) do
    assigns[:<%= file_name %>] = @<%= file_name %> = stub_model(<%= class_name %>,
      :new_record? => false<%= output_attributes.empty? ? '' : ',' %>
<% output_attributes.each_with_index do |attribute, attribute_index| -%>
      :<%= attribute.name %> => <%= attribute.default_value %><%= attribute_index == output_attributes.length - 1 ? '' : ','%>
<% end -%>
    )
  end

  it "renders the edit <%= file_name %> form" do
    <% if ! options[:skip_confirmation] %>
    render :helper => "scaffold_with_confirmation"
    <% else %>
    render
    <% end %>

    response.should have_tag("form[action=#{<%= singular_path %>_path(@<%= file_name %>)}/preview][method=post]") do
<% for attribute in output_attributes -%>
      with_tag('<%= attribute.input_type -%>#<%= file_name %>_<%= attribute.name %>[name=?]', "<%= file_name %>[<%= attribute.name %>]")
<% end -%>
    end
  end
end
