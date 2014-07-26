module Spree
  class SubscriptionEvent < ActiveRecord::Base
    serialize :response, JSON

    belongs_to :subscription
    validates :event_id, :subscription_id, presence: true
    validates :event_id, uniqueness: true

    attr_readonly :event_id, :subscription_id, :request_type

    def parsed_response
      JSON.parse response
    end
  end
end
