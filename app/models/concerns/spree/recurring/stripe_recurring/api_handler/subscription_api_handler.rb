module Spree
  class Recurring < ActiveRecord::Base
    class StripeRecurring < Spree::Recurring
      module ApiHandler
        module SubscriptionApiHandler
          def subscribe subscription
            raise_invalid_object_error(subscription, Spree::Subscription)
            customer = subscription.user.find_or_create_stripe_customer(subscription.card_token)
            customer.subscriptions.create(extra_opts(subscription).merge(plan: subscription.api_plan_id, card: subscription.card_token))
          end

          def change_plan subscription
            raise_invalid_object_error(subscription, Spree::Subscription)
            subscription.user.api_customer.update_subscription(extra_opts(subscription).merge(plan: subscription.api_plan_id, card: subscription.card_token))
          end

          def unsubscribe subscription
            raise_invalid_object_error(subscription, Spree::Subscription)
            subscription.user.api_customer.cancel_subscription(cancelation_opts)
          end

          def extra_opts subscription
            subscription.stripe_opts.presence || {}
          end

          def cancelation_opts
            {at_period_end: true}
          end
        end
      end
    end
  end
end
