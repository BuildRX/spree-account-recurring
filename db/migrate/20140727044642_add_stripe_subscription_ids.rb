class AddStripeSubscriptionIds < ActiveRecord::Migration
  def change
    add_column :spree_subscriptions, :stripe_subscription_id, :string
  end
end
