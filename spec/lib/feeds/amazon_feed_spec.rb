require 'spec_helper'

module Feeds
  describe AmazonFeed do
    let(:config) {{ 'amazon.aws_access_key' => ENV['MWS_KEY'], 'amazon.secret_key' => ENV['MWS_SECRET_KEY'],
                    'amazon.seller_id' => ENV['MWS_MERCHANT'] }}

    context '#submit' do
      it 'should submit a feed' do

          now = Time.new(2013, 10, 22, 13, 22, 33, "-04:00")
          Timecop.freeze(now)
        VCR.use_cassette('submit_feed') do
          doc = OrderFulfillment.new(Factories.shipment, ENV['MWS_MERCHANT']).to_xml

          res = AmazonFeed.new(config).submit('_POST_ORDER_FULFILLMENT_DATA_', doc)
          res.include?('<FeedSubmissionId>8252123906</FeedSubmissionId>').should eq true
        end
      end
    end
  end
end