require 'test_helper'

class <%= controller_class_name %>ControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:<%= plural_name %>)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get create confirm" do
    post :create_confirm, :<%= table_name.singularize %> => { }
    assert_response :success
    assert_not_nil assigns(:<%= singular_name %>)
  end

  test "should reset new <%= file_name %>" do
    post :create_confirm, :<%= table_name.singularize %> => { }, :reset => true
    assert_redirected_to new_<%= singular_path %>_url
  end

  test "should create <%= file_name %>" do
    assert_difference('<%= class_name %>.count') do
      post :create, :<%= table_name.singularize %> => { }
    end

    assert_redirected_to <%= singular_path %>_url(assigns(:<%= singular_name %>))
  end

  test "should reedit new <%= file_name %>" do
    post :create, :<%= table_name.singularize %> => { }, :edit => true
    assert_response :success
    assert_not_nil assigns(:<%= singular_name %>)
  end

  test "should show <%= file_name %>" do
    get :show, :id => <%= plural_name %>(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => <%= plural_name %>(:one).to_param
    assert_response :success
  end

  test "should get update confirm" do
    put :update_confirm, :id => <%= plural_name %>(:one).to_param, :<%= table_name.singularize %> => { }
    assert_response :success
    assert_not_nil assigns(:<%= singular_name %>)
  end

  test "should reset update <%= file_name %>" do
    put :update_confirm, :id => <%= plural_name %>(:one).to_param, :<%= table_name.singularize %> => { }, :reset => true
    assert_redirected_to edit_<%= singular_path %>_url(assigns(:<%= singular_name %>))
  end

  test "should update <%= file_name %>" do
    put :update, :id => <%= plural_name %>(:one).to_param, :<%= table_name.singularize %> => { }
    assert_redirected_to <%= singular_path %>_url(assigns(:<%= singular_name %>))
  end

  test "should reedit update <%= file_name %>" do
    put :update, :id => <%= plural_name %>(:one).to_param, :<%= table_name.singularize %> => { }, :edit => true
    assert_response :success
    assert_not_nil assigns(:<%= singular_name %>)
  end

  test "should destroy <%= file_name %>" do
    assert_difference('<%= class_name %>.count', -1) do
      delete :destroy, :id => <%= plural_name %>(:one).to_param
    end

    assert_redirected_to <%= plural_path %>_path
  end
end
