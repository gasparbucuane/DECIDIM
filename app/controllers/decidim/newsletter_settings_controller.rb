# frozen_string_literal: true

module Decidim
  class NewsletterSettingsController < Decidim::ApplicationController
    include Decidim::UserProfile

    before_action :authenticate_user!
    before_action :load_processes

    def show; end

    private

    def load_processes
      @processes = Decidim::ParticipatoryProcess
                   .where(organization: current_organization)
                   .published
                   .order(weight: :asc)
                   .select { |process| !process.private_space? || process.can_participate?(current_user) }
    end
  end
end