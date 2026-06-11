
STATIC_ADDITIONAL_USERS = 100

Decidim.stats.register :Participantes,
                        priority: Decidim::StatsRegistry::HIGH_PRIORITY,
                        icon_name: "user-line",
                        tooltip_key: "Número total de usuários" do |organization, start_at, end_at|                      
  # Usuários que interagiram no chatbot
  chatbot_users = Decidim::Chatbot::Sender.where(decidim_user: organization.users)
  chatbot_users = chatbot_users.where(created_at: start_at..) if start_at.present?
  chatbot_users = chatbot_users.where(created_at: ..end_at) if end_at.present?
  chatbot_user_ids = chatbot_users.distinct.pluck(:decidim_user_id).compact

  # Usuários que interagiram no website (não bloqueados, não deletados)
  website_users = organization.users
                    .where(type: "Decidim::User")
                    .where(blocked: false)
                    .where(deleted_at: nil)

  website_users = website_users.where("last_sign_in_at >= ?", start_at) if start_at.present?
  website_users = website_users.where("last_sign_in_at <= ?", end_at) if end_at.present?
  website_user_ids = website_users.pluck(:id)

  # Unir, contar usuários únicos e adicionar 100 usuários fixos
  (chatbot_user_ids + website_user_ids).uniq.count + STATIC_ADDITIONAL_USERS
end


