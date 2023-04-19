require 'test_helper'

class Admin::PostcodesControllerTest < ActionDispatch::IntegrationTest
  test "should get ncsv" do
    get admin_postcodes_ncsv_url
    assert_response :success
  end

end
