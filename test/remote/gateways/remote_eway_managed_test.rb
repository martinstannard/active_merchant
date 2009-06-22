require File.dirname(__FILE__) + '/../../test_helper'

class EwayManagedTest < Test::Unit::TestCase

  def setup
    Base.gateway_mode = :test
    @gateway = EwayGateway.new(fixtures(:eway_managed))

    @customer_params = {
      :order_id => '1230123',
      :email => 'bob@testbob.com',
      :title => 'Mr',
      :first_name => 'Bob',
      :last_name => 'Stewart',
      :address => '47 Bobway',
      :suburb => 'Bobville',
      :state => 'WA',
      :country => 'AU',
      :post_code => '2000',
      :phone_1 => '12341234',
      :phone_2 => '12341235',
      :fax => '12341236',
      :company => 'Bob Industries',
      :ref => 'Customer Reference',
      :job_desc => 'Job Description',
      :comments => 'Comments',
      :url => 'http://www.bob.com'
    }

    @credit_card_params = {
      :first_name         => 'martin',
      :last_name          => 'stannard',
      :type               => 'visa',
      :number             => '4444333322221111',
      :verification_value => '123',
      :month              => 12,
      :year               => 2010
    }

    @credit_card_fail = {
      :first_name         => 'martin',
      :last_name          => 'stannard',
      :type               => 'visa',
      :number             => '1111222233334444',
      :verification_value => '123',
      :month              => 12,
      :year               => 2010
    }

    @login_options = {
      :login => '87654321',
      :username => 'test@eway.com.au',
      :password => 'test123',
      :engine => 'managed'
    }
  end

  # managed customer methods
  def test_customer_create
    c = EwayManaged::Customer.new @customer_params, @login_options
    puts 'options'
    puts c.options.inspect
    c.credit_card = ActiveMerchant::Billing::CreditCard.new(@credit_card_params)
    puts c.credit_card.inspect
    assert c.create
    #assert_instance_of EwayManaged::CustomerResponse, res
  end

  def test_customer_new
    flunk
  end

  def test_customer_save
    flunk
  end

  def test_customer_save!
    flunk
  end

  def test_customer_update
    flunk
  end

  def test_customer_query
    flunk
  end

  def test_customer_validate
    flunk
  end

  def test_customer_prepared_attributes
    flunk
  end

  def test_customer_credit_card
    flunk
  end


end
