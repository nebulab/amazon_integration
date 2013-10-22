require 'spec_helper'


describe AmazonEndpoint do

  let(:config) { [{ name: "amazon.marketplace_id",     value: 'ATVPDKIKX0DER'},
                  { name: "amazon.seller_id",          value: 'A6WWS5LKYVEJ8'},
                  { name: 'amazon.last_updated_after', value: '2013-06-12'},
                  { name: 'amazon.aws_access_key',     value: 'AKIAIR24VLFSLJRUCXBQ'},
                  { name: 'amazon.secret_key',         value: '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' }] }

  let(:message) { { message_id: '1234567' } }

  let(:request) { { message: 'amazon:order:poll',
                    message_id: '1234567',
                    payload: { parameters: config } } }

  def auth
    { 'HTTP_X_AUGURY_TOKEN' => 'x123', 'CONTENT_TYPE' => 'application/json' }
  end

  def app
    AmazonEndpoint
  end

  describe '/get_orders' do
    before do
      now = Time.new(2013, 8, 16, 10, 55, 14, '-03:00')
      Timecop.freeze(now)
    end

    after  { Timecop.return }

    it 'gets orders from amazon' do
      VCR.use_cassette('amazon_client_valid_orders') do
        post '/get_orders', request.to_json, auth

        expect(last_response).to be_ok
        expect(json_response['message_id']).to eq('1234567')
      end
    end
  end

  describe '/get_order_by_number' do
    before do
      now = Time.new(2013, 8, 23, 19, 25, 14, '-03:00')
      Timecop.freeze(now)
    end

    after  { Timecop.return }

    it 'gets order by number from amazon' do
      VCR.use_cassette('amazon_client_valid_order_by_number') do
        request[:payload][:amazon_order_id] = '102-1580746-9061828'
        post '/get_order_by_number', request.to_json, auth

        expect(last_response).to be_ok
        expect(json_response['message_id']).to eq('1234567')
      end
    end
  end

  describe '/get_inventory_by_sku' do
    before do
      now = Time.new(2013, 10, 21, 17, 30, 14, '-03:00')
      Timecop.freeze(now)
    end

    after  { Timecop.return }

    it 'gets inventory by sku from amazon' do
      VCR.use_cassette('amazon_client_inventory_by_sku') do
        request[:payload][:sku] = 'OX-M0NP-AOD1'
        post '/get_inventory_by_sku', request.to_json, auth

        expect(last_response).to be_ok
        expect(json_response['message_id']).to eq('1234567')
        expect(json_response['messages']).to have(1).item
        expect(json_response['messages'].first['payload']['sku']).to eq('OX-M0NP-AOD1')
      end
    end
  end
end

