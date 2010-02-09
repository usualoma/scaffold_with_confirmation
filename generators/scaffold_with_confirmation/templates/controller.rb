class <%= controller_class_name %>Controller < ApplicationController
  <% if ! options[:skip_confirmation] %>
  helper ScaffoldWithConfirmationHelper

  <% end %>
  # GET /<%= plural_path %>
  # GET /<%= plural_path %>.xml
  def index
    @<%= plural_name %> = <%= class_name %>.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @<%= plural_name %> }
    end
  end

  # GET /<%= plural_path %>/1
  # GET /<%= plural_path %>/1.xml
  def show
    @<%= singular_name %> = <%= class_name %>.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @<%= singular_name %> }
    end
  end

  # GET /<%= plural_path %>/new
  # GET /<%= plural_path %>/new.xml
  def new
    @<%= singular_name %> = <%= class_name %>.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @<%= singular_name %> }
    end
  end

  # GET /<%= plural_path %>/1/edit
  def edit
    @<%= singular_name %> = <%= class_name %>.find(params[:id])
  end
  <% if ! options[:skip_confirmation] %>

  # POST /<%= plural_path %>/preview
  # POST /<%= plural_path %>/preview.xml
  def preview_creation
    if params.key?('reset')
      return respond_to do |format|
        format.html { redirect_to(new_<%= singular_path %>_url) }
        format.xml  { head :ok }
      end
    end

    @<%= singular_name %> = <%= class_name %>.new(params[:<%= table_name.singularize %>])

    respond_to do |format|
      if @<%= singular_name %>.valid?
        format.html # preview_creation.html.erb
        format.xml  { render :xml => @<%= singular_name %> }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @<%= singular_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  <% end %>
  # POST /<%= plural_path %>
  # POST /<%= plural_path %>.xml
  def create
    @<%= singular_name %> = <%= class_name %>.new(params[:<%= table_name.singularize %>])

    respond_to do |format|
      if ! params.key?('edit') && @<%= singular_name %>.save
        flash[:notice] = '<%= class_name %> was successfully created.'
        format.html { redirect_to(<%= singular_path %>_url(@<%= singular_name %>)) }
        format.xml  { render :xml => @<%= singular_name %>, :status => :created, :location => @<%= singular_name %> }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @<%= singular_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end
  <% if ! options[:skip_confirmation] %>

  # POST /<%= plural_path %>/1/preview
  # POST /<%= plural_path %>/1/preview.xml
  def preview_update
    @<%= singular_name %> = <%= class_name %>.find(params[:id])
    if params.key?('reset')
      return respond_to do |format|
        format.html { redirect_to(edit_<%= singular_path %>_url(@<%= singular_name %>)) }
        format.xml  { head :ok }
      end
    end

    @<%= singular_name %>.attributes = params[:<%= table_name.singularize %>]

    respond_to do |format|
      if @<%= singular_name %>.valid?
        format.html # edit_confirm.html.erb
        format.xml  { render :xml => @<%= singular_name %> }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @<%= singular_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  <% end %>
  # PUT /<%= plural_path %>/1
  # PUT /<%= plural_path %>/1.xml
  def update
    @<%= singular_name %> = <%= class_name %>.find(params[:id])
    @<%= singular_name %>.attributes = params[:<%= table_name.singularize %>]

    respond_to do |format|
      if ! params.key?('edit') && @<%= singular_name %>.save
        flash[:notice] = '<%= class_name %> was successfully updated.'
        format.html { redirect_to(<%= singular_path %>_url(@<%= singular_name %>)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @<%= singular_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /<%= plural_path %>/1
  # DELETE /<%= plural_path %>/1.xml
  def destroy
    @<%= singular_name %> = <%= class_name %>.find(params[:id])
    @<%= singular_name %>.destroy

    respond_to do |format|
      format.html { redirect_to(<%= plural_path %>_url) }
      format.xml  { head :ok }
    end
  end
end
