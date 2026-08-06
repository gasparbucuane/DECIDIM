STATIC_ADDITIONAL_USERS = 100

Decidim.stats.register :Participantes,
                        priority: Decidim::StatsRegistry::HIGH_PRIORITY,
                        icon_name: "user-line",
                        tooltip_key: "Número total de usuários" do |organization, start_at, end_at|
  # Todos os senders do chatbot (incluindo os sem decidim_user_id), sem duplicidade
  chatbot_senders = Decidim::Chatbot::Sender.all
  chatbot_senders = chatbot_senders.where(created_at: start_at..) if start_at.present?
  chatbot_senders = chatbot_senders.where(created_at: ..end_at) if end_at.present?

  # IDs únicos dos senders que têm decidim_user
  chatbot_user_ids = chatbot_senders.where.not(decidim_user_id: nil).distinct.pluck(:decidim_user_id)

  # Senders anónimos (sem decidim_user_id) — cada um conta como participante único
  anonymous_senders_count = chatbot_senders.where(decidim_user_id: nil).count

  # Usuários que interagiram no website (não bloqueados, não deletados)
  website_users = organization.users
                    .where(type: "Decidim::User")
                    .where(blocked: false)
                    .where(deleted_at: nil)

  website_users = website_users.where("last_sign_in_at >= ?", start_at) if start_at.present?
  website_users = website_users.where("last_sign_in_at <= ?", end_at) if end_at.present?
  website_user_ids = website_users.pluck(:id)

  # Unir users (chatbot + website) sem duplicados + anónimos + 100 fixos
  (chatbot_user_ids + website_user_ids).uniq.count + anonymous_senders_count + STATIC_ADDITIONAL_USERS
end
