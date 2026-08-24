Rails.application.config.to_prepare do
  require_dependency "password_validator"

  if PasswordValidator::MINIMUM_LENGTH != 6
    PasswordValidator.send(:remove_const, :MINIMUM_LENGTH)
    PasswordValidator.const_set(:MINIMUM_LENGTH, 6)
  end
end
Decidim.configure do |config|
  config.admin_password_min_length = 6
  config.default_locale = :pt
  config.available_locales = [:pt, :"pt-BR"]
 end

Rails.application.config.after_initialize do
  I18n.fallbacks.map(pt: :"pt-BR")
end
