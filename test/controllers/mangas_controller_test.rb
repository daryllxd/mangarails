require 'test_helper'

class MangasControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get mangas_index_url
    assert_response :success
  end

end
