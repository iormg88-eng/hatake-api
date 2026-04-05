class Api::V1::WebhooksController < ApplicationController
  skip_before_action :authenticate_user!

  def stripe
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, ENV["STRIPE_WEBHOOK_SECRET"])
    rescue Stripe::SignatureVerificationError
      return render json: { errors: [ "Invalid signature" ] }, status: :bad_request
    end

    case event["type"]
    when "checkout.session.completed"
      session = event["data"]["object"]
      user_id = session.dig("metadata", "user_id")
      user = User.find_by(id: user_id)
      if user
        user.update!(
          plan: "pro",
          stripe_customer_id: session["customer"],
          stripe_subscription_id: session["subscription"]
        )
      end
    when "customer.subscription.deleted"
      subscription = event["data"]["object"]
      user = User.find_by(stripe_subscription_id: subscription["id"])
      user&.update!(plan: "free", stripe_subscription_id: nil)
    end

    head :ok
  end
end
