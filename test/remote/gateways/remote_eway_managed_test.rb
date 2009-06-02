require File.dirname(__FILE__) + '/../../test_helper'

class EwayManagedTest < Test::Unit::TestCase
  def setup
    Base.gateway_mode = :test
    @gateway = EwayGateway.new(fixtures(:eway_managed))

    @credit_card_success = credit_card('4444333322221111')

    @credit_card_fail = credit_card('1234567812345678',
                                    :month => Time.now.month,
                                    :year => Time.now.year
                                   )

    @recurring_params = {
      :order_id => '1230123',
      :email => 'bob@testbob.com',
      :first_name => 'Bob',
      :last_name => 'Stewart',

      :customer => {} ,
      :billing_address => { :address1 => '47 Bobway',
        :city => 'Bobville',
        :state => 'WA',
        :country => 'AU',
        :zip => '2000'
    } ,
      :description => 'Ongoing Purchase',
      :starting_at => DateTime.now + 1.day,
      :ending_at => DateTime.new + 1.day + 1.year,
      :periodicity => :weekly
    }

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
  end

  def test_create_customer
    credit_card ||= ActiveMerchant::Billing::CreditCard.new(@credit_card_params)
    customer = @gateway.create_customer(credit_card, @customer_params)
    assert_false customer.error?
    assert_not_nil customer.id
  end

  def test_invalid_create_customer
    credit_card ||= ActiveMerchant::Billing::CreditCard.new(@credit_card_params)
    params = @customer_params.dup
    params[:first_name] = ''
    assert_raises StandardError do
      @gateway.create_customer(credit_card, params)
    end
  end

  def test_query_customer
    customer = @gateway.query_customer('9876543211000')

    assert("customer reference", customer.ref)
    assert("mr", customer.title)
    assert("firstname", customer.first_name)
    assert("lastname", customer.last_name)
    assert("company", customer.company)
    assert("job description", customer.job_description)
    assert("email", customer.email)
    assert("address", customer.address)
    assert("suburb", customer.suburb)
    assert("canberra", customer.state)
    assert("9999", customer.post_code)
    assert("1111111111", customer.phone_1)
    assert("2222222222", customer.phone_2)
    assert("fax", customer.fax)
    assert("ACT", customer.state)
    assert("country", customer.country)
    assert("http://www.eway.com.au", customer.url)
    assert("comments", customer.comments)
  end

  def test_update_customer
    credit_card = ActiveMerchant::Billing::CreditCard.new(@credit_card_params)
    response =  @gateway.update_customer('9876543211000', credit_card, @customer_params)

    assert response
  end

  def test_invalid_update_customer
    params = @customer_params.dup
    params[:first_name] = ''
    credit_card = ActiveMerchant::Billing::CreditCard.new(@credit_card_params)
    customer = @gateway.create_customer(credit_card, @customer_params)
    params = @customer_params.dup
    credit_card = ActiveMerchant::Billing::CreditCard.new(@credit_card_params)
    assert_raises SOAP::FaultError do
      @gateway.update_customer(customer.id, credit_card, params)
    end
  end

  def test_delete_customer
    credit_card = ActiveMerchant::Billing::CreditCard.new(@credit_card_params)
    customer = @gateway.create_customer(credit_card, @customer_params)
    response = @gateway.delete_customer(customer.id)
    assert_false customer.error?
  end
end
