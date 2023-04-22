require 'test_helper'

class Admin::PostcodesControllerTest < ActionDispatch::IntegrationTest
  test "should get process_csv" do
    get admin_postcodes_process_csv_url
    assert_response :success
  end

end
