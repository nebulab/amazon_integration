require 'spec_helper'

module Feeds
  describe AmazonFeed do
    let(:config) {{ 'amazon.aws_access_key' => ENV['AWS_ACCESS_KEY'],
                    'amazon.secret_key'     => ENV['SECRET_KEY'],
                    'amazon.seller_id'      => ENV['SELLER_ID'] } }

    context '#submit' do
      before do
        now = Time.new(2013, 10, 22, 15, 51, 11, '-04:00')
        # Timecop.freeze(now)
        Time.stub(now: now)
      end

      it 'should submit a feed' do
        VCR.use_cassette('submit_feed') do
          doc = OrderFulfillment.new(Factories.shipment, ENV['MWS_MERCHANT']).to_xml
          res = AmazonFeed.new(config).submit('_POST_ORDER_FULFILLMENT_DATA_', doc)
          expect(res[:messages].first[:payload][:feed_id]).to eq '8253017998'
        end
      end
    end

    describe '#status' do
      before do
        now = Time.new(2013, 10, 22, 21, 39, 01, '-04:00')
        # Timecop.freeze(now)
        Time.stub(now: now)
      end

      # after  { Timecop.return }

      it 'should return the status of a feed' do
        VCR.use_cassette('feed_status') do
          res = AmazonFeed.new(config).status('8253017998')
          expect(res[:notifications].first[:description]).to eq 'Succesfully processed feed # 8253017998'
        end
      end
    end
  end
end
