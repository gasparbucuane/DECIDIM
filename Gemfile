# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

DECIDIM_VERSION = { github: "decidim/decidim", branch: "release/0.31-stable" }.freeze
gem "decidim", DECIDIM_VERSION
gem "decidim-chatbot", github: "openpoke/decidim-module-chatbot", branch: "tmp-proposal-fix"
gem "decidim-decidim_awesome", github: "decidim-ice/decidim-module-decidim_awesome", branch: "main"
gem "decidim-term_customizer", github: "openpoke/decidim-module-term_customizer", branch: "main"

# Optional Decidim modules
# gem "decidim-ai", "0.31.0"
# gem "decidim-collaborative_texts", "0.31.0"
# gem "decidim-conferences", "0.31.0"
# gem "decidim-demographics", "0.31.0"
# gem "decidim-design", "0.31.0"
# gem "decidim-elections", "0.31.0"
# gem "decidim-initiatives", "0.31.0"
# gem "decidim-templates", "0.31.0"

gem "bootsnap", "~> 1.3"

gem "health_check"
gem "puma", ">= 6.3.1"
gem "sidekiq"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "brakeman", "~> 7.0"
  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "letter_opener_web"
  gem "listen", "~> 3.1"
  gem "web-console", "~> 4.2"
end
