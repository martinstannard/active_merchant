require File.dirname(__FILE__) + '/../../test_helper'

class EwayTest < Test::Unit::TestCase
  def setup
    Base.gateway_mode = :test
    @gateway = EwayGateway.new(fixtures(:eway_managed))

    @credit_card_success = credit_card('4444333322221111')

    @credit_card_fail = credit_card('1234567812345678',
                                    :month => Time.now.month,
                                    :year => Time.now.year
                                   )

                                   @credit_card_params = {
                                     :first_name         => 'martin',
                                     :last_name          => 'stannard',
                                     :type               => 'visa',
                                     :number             => '4444333322221111',
                                     :verification_value => '123',
                                     :month              => 12,
                                     :year               => 2010
                                   }

                                   @params = {
                                     :order_id => '1230123',
                                     :email => 'bob@testbob.com',
                                     :first_name => 'bob',
                                     :last_name => 'loblaw',
                                     :billing_address => { :address1 => '47 Bobway',
                                       :city => 'Bobville',
                                       :state => 'WA',
                                       :country => 'AU',
                                       :zip => '2000'
                                   } ,
                                   :description => 'purchased items'
                                   }
  end

  def test_new_customer
    assert customer = @gateway.new_customer(@params, :engine => :managed) 
    assert_instance_of EwayManaged::Customer, customer
    assert_equal 0, customer.errors.size
  end

  def test_create_customer
    assert customer = @gateway.new_customer(@params, :engine => :managed) 
    assert_equal 0, customer.errors.size
    assert customer = @gateway.create_customer(credit_card, customer, :engine => :managed) 
    assert_instance_of EwayManaged::Customer, customer
  end

  def test_new_customer_no_first_name
    customer = @gateway.new_customer(@params.merge(:first_name => nil), :engine => :managed) 
    assert response = @gateway.create_customer(credit_card, customer, :engine => :managed) 
    assert_instance_of EwayManaged::Customer, response
    assert_equal 1, response.errors.size
    assert_failure response
  end

  def test_new_customer_no_last_name
    customer = @gateway.new_customer(@params.merge(:last_name => nil), :engine => :managed) 
    assert response = @gateway.create_customer(credit_card, customer, :engine => :managed) 
    assert_instance_of EwayManaged::Customer, response
    assert_equal 1, response.errors.size
    assert_failure response
  end

  def test_new_customer_no_email
    customer = @gateway.new_customer(@params.merge(:email => nil), :engine => :managed) 
    assert_raises(StandardError) { response = @gateway.create_customer(credit_card, customer, :engine => :managed) }
    begin
      @gateway.create_customer(credit_card, customer, :engine => :managed)
    rescue StandardError => response
      assert_instance_of StandardError, response
      assert_equal 1, response.errors.size
      assert_failure response
    end
  end

  def test_invalid_ccv
    customer = @gateway.new_customer(@params, :engine => :managed) 
    assert response = @gateway.create_customer(credit_card('4444333322221111', :verification_value => 'abcdef'), customer, :engine => :managed) 
    puts response.inspect
    assert_instance_of EwayManaged::Customer, response
    assert_equal 1, response.credit_card.errors.size
    assert_equal 'Number is not a valid credit card number', response.credit_card.errors.full_messages.to_s
    assert_failure response
  end

  def test_invalid_cc_number
    cc = ActiveMerchant::Billing::CreditCard.new(@credit_card_params.merge(:verification_value => 'abcdef'))
    customer = @gateway.new_customer(@params, :engine => :managed) 
    assert response = @gateway.create_customer(cc, customer, :engine => :managed) 
    assert_instance_of EwayManaged::Customer, response
    assert_equal 1, response.credit_card.errors.size
    assert_equal 'Number is not a valid credit card number', response.credit_card.errors.full_messages.to_s
    assert_failure response
  end

  def test_invalid_amount
    assert response = @gateway.purchase(101, @credit_card_success, @params)
    assert_failure response
    assert response.test?
    assert_equal EwayGateway::MESSAGES["01"], response.message
  end

  def test_purchase_success_with_verification_value 
    assert response = @gateway.purchase(100, @credit_card_success, @params)
    assert_equal '123456', response.authorization
    assert_success response
    assert response.test?
    assert_equal EwayGateway::MESSAGES["00"], response.message
  end

  def test_purchase_success_without_address
    assert response = @gateway.purchase(100, @credit_card_success, @params.except(:billing_address))
    assert_equal '123456', response.authorization
    assert_success response
    assert response.test?
    assert_equal EwayGateway::MESSAGES["00"], response.message
  end

  def test_invalid_expiration_date
    @credit_card_success.year = 2005 
    assert response = @gateway.purchase(100, @credit_card_success, @params)
    assert_failure response
    assert response.test?
  end

  def test_purchase_with_invalid_verification_value
    @credit_card_success.verification_value = 'AAA' 
    assert response = @gateway.purchase(100, @credit_card_success, @params)
    assert_nil response.authorization
    assert_failure response
    assert response.test?
  end

  def test_purchase_success_without_verification_value
    @credit_card_success.verification_value = nil

    assert response = @gateway.purchase(100, @credit_card_success, @params)
    assert_equal '123456', response.authorization
    assert_success response
    assert response.test?
    assert_equal EwayGateway::MESSAGES["00"], response.message
  end

  def test_purchase_error
    assert response = @gateway.purchase(100, @credit_card_fail, @params)
    assert_nil response.authorization
    assert_equal false, response.success?
    assert response.test?
  end
end
