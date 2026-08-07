# config/initializers/rails_secrets_compat.rb
Rails::Application.class_eval do
  def secrets
    @secrets ||= ActiveSupport::OrderedOptions.new.merge!(credentials.to_h)
  end
end
