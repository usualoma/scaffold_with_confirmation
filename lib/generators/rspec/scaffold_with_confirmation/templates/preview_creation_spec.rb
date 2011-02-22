require 'spec_helper'

<% output_attributes = attributes.reject{|attribute| [:datetime, :timestamp, :time, :date].index(attribute.type) } -%>
describe "<%= table_name %>/preview_creation.html.<%= options[:template_engine] %>" do
  before(:each) do
    @<%= file_name %> = <%= class_name %>.new
    params[:<%= file_name %>] = {
<% output_attributes.each_with_index do |attribute, attribute_index| -%>
      :<%= attribute.name %> => <%= attribute.default.inspect %><%= attribute_index == output_attributes.length - 1 ? '' : ','%>
<% end -%>
    }
  end

  it "renders the edit <%= file_name %> form" do
    view.singleton_class.send :include, ScaffoldWithConfirmationHelper
    render

<% if webrat? -%>
    rendered.should have_selector("form", :action => <%= file_name %>_path(@<%= file_name %>), :method => "post") do |form|
<% for attribute in output_attributes -%>
      form.should have_selector("<%= attribute.input_type -%>#<%= file_name %>_<%= attribute.name %>", :name => "<%= file_name %>[<%= attribute.name %>]")
<% end -%>
    end
<% else -%>
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => new_<%= file_name %>_path, :method => "post"
<% end -%>
  end
end
