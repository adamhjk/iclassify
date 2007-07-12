require File.dirname(__FILE__) + '/../test_helper'
require 'nodes_controller'

# Re-raise errors caught by the controller.
class NodesController; def rescue_action(e) raise e end; end

class NodesControllerTest < Test::Unit::TestCase
  fixtures :nodes

  def setup
    @controller = NodesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:nodes)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_node
    old_count = Node.count
    post :create, :node => { }
    assert_equal old_count+1, Node.count
    
    assert_redirected_to node_path(assigns(:node))
  end

  def test_should_show_node
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_node
    put :update, :id => 1, :node => { }
    assert_redirected_to node_path(assigns(:node))
  end
  
  def test_should_destroy_node
    old_count = Node.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Node.count
    
    assert_redirected_to nodes_path
  end
end
