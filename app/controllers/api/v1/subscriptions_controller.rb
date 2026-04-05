class Api::V1::SubscriptionsController < ApplicationController
  def create_checkout
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]

    session = Stripe::Checkout::Session.create(
      mode: "subscription",
      customer_email: current_user.email,
      line_items: [ { price: ENV["STRIPE_PRO_PRICE_ID"], quantity: 1 } ],
      success_url: "#{ENV.fetch("FRONTEND_URL", "http://localhost:3000")}/dashboard/fields?upgraded=true",
      cancel_url: "#{ENV.fetch("FRONTEND_URL", "http://localhost:3000")}/dashboard/settings",
      metadata: { user_id: current_user.id }
    )

    render json: { url: session.url }
  rescue Stripe::StripeError => e
    render json: { errors: [ e.message ] }, status: :unprocessable_entity
  end
end
