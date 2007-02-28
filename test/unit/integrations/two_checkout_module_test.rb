require File.dirname(__FILE__) + '/../../test_helper'

class TwoCheckoutModuleTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations
  
  def test_notification_method
    assert_instance_of TwoCheckout::Notification, TwoCheckout.notification('name=cody')
  end
end 