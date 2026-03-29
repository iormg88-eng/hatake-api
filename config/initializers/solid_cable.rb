if Rails.env.production?
  Rails.application.config.after_initialize do
    if defined?(SolidCable)
      ActionCable.server.config.cable = { "adapter" => "async" }
    end
  end
end
