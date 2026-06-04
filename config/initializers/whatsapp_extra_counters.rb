Decidim.stats.register :users_count,
                        priority: Decidim::StatsRegistry::HIGH_PRIORITY,
                        icon_name: "user-line",
                        tooltip_key: "users_count_tooltip" do |organization, start_at, end_at|
  users = Decidim::Chatbot::Sender.where(decidim_user: organization.users)
  users = users.where(created_at: start_at..) if start_at.present?
  users = users.where(created_at: ..end_at) if end_at.present?
  users.count
end

