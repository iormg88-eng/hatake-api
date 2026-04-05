class AddPlanAndStripeToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :plan, :string, default: "free", null: false
    add_column :users, :stripe_customer_id, :string
    add_column :users, :stripe_subscription_id, :string
  end
end
