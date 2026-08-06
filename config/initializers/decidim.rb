Rails.application.config.to_prepare do
  require_dependency "password_validator"

  if PasswordValidator::MINIMUM_LENGTH != 6
    PasswordValidator.send(:remove_const, :MINIMUM_LENGTH)
    PasswordValidator.const_set(:MINIMUM_LENGTH, 6)
  end
end

Decidim.configure do |config|
  config.admin_password_min_length = 6
end
