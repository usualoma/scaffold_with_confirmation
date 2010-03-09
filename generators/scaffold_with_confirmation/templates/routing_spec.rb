require 'spec_helper'

describe <%= controller_class_name %>Controller do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/<%= plural_web_path %>" }.should route_to(:controller => "<%= plural_web_path %>", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/<%= plural_web_path %>/new" }.should route_to(:controller => "<%= plural_web_path %>", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/<%= plural_web_path %>/1" }.should route_to(:controller => "<%= plural_web_path %>", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/<%= plural_web_path %>/1/edit" }.should route_to(:controller => "<%= plural_web_path %>", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/<%= plural_web_path %>" }.should route_to(:controller => "<%= plural_web_path %>", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/<%= plural_web_path %>/1" }.should route_to(:controller => "<%= plural_web_path %>", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/<%= plural_web_path %>/1" }.should route_to(:controller => "<%= plural_web_path %>", :action => "destroy", :id => "1") 
    end
  end
end
