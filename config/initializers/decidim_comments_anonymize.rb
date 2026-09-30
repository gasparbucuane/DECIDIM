# frozen_string_literal: true

module Decidim
  module Comments
    class AnonymousAuthorPresenter
      def initialize(name)
        @name = name
      end

      def name
        @name
      end

      def nickname
        ""
      end

      def badge
        ""
      end

      def avatar_url(_variant = nil)
        ActionController::Base.helpers.asset_pack_path("media/images/default-avatar.svg")
      rescue StandardError
        ""
      end

      def profile_path
        ""
      end

      def profile_url
        ""
      end

      def deleted?
        false
      end

      def can_be_contacted?
        false
      end

      def official?
        false
      end

      def presenter
        self
      end
    end
  end
end

Rails.application.config.to_prepare do
  Decidim::Comments::CommentCell.class_eval do
    private

    def author_presenter
      Decidim::Comments::AnonymousAuthorPresenter.new(anonymous_display_name)
    end

    def anonymous_display_name
      author_id = model.decidim_author_id || model.author&.id
      scope = "#{model.decidim_commentable_type}-#{model.decidim_commentable_id}"
      digest = OpenSSL::HMAC.hexdigest("SHA256", Rails.application.secret_key_base, "#{scope}-#{author_id}")
      "anonimo.#{digest[0, 4]}"
    end  
  end
end
