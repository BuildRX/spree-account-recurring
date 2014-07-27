module Spree
  class Recurring < ActiveRecord::Base
    class StripeRecurring < Spree::Recurring
      module ApiHandler
        module SubscriptionApiHandler
          def subscribe subscription
            raise_invalid_object_error(subscription, Spree::Subscription)

            # garbage logic because Stripe tokens cannot be reused.
            # if we need to create a customer from a token,
            # we need to omit card_token from subscription

            user = subscription.user

            api_subscription = if user.stripe_customer_id
              customer = user.api_customer
              customer.subscriptions.create opts(subscription)
            else
              customer = user.find_or_create_stripe_customer(subscription.card_token)
              customer.subscriptions.create opts(subscription, true)
            end

            subscription.stripe_subscription_id = api_subscription.try(:id)
          end

          def change_plan subscription
            raise_invalid_object_error(subscription, Spree::Subscription)
            subscription.user.api_customer.update_subscription opts(subscription)
          end

          def unsubscribe subscription
            raise_invalid_object_error(subscription, Spree::Subscription)
            #subscription.user.api_customer.cancel_subscription cancelation_opts(subscription)
            subscription.user.api_customer.subscriptions.retrieve(subscription.stripe_subscription_id).delete cancelation_opts(subscription)
          end

          def opts sub, omit_card = false
            base = {plan: sub.api_plan_id}
            base.merge!(sub.stripe_opts) if sub.stripe_opts.present?
            base[:card] = sub.card_token if sub.card_token and !omit_card
            puts base
            base
          end

          def cancelation_opts sub
            if sub.future?
              {} # we can cancel right away, customer hasn't been billed yet
            else
              {at_period_end: true}
            end
          end
        end
      end
    end
  end
end
