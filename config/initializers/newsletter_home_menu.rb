# frozen_string_literal: true

Decidim.menu :home_content_block_menu do |menu|
  menu.add_item :newsletter,
                I18n.t("menu.newsletter", scope: "decidim"),
                "/newsletter-settings",
                position: 90,
                if: current_organization&.id == 1
end