# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class PodcastCarouselCell < Decidim::ViewModel
      PODCAST_SLOTS = (1..20).map { |index| format("podcast_%02d", index).to_sym }.freeze

      SOCIAL_NETWORKS = [
        { key: :whatsapp, name: "WhatsApp", icon: "whatsapp-line" },
        { key: :facebook, name: "Facebook", icon: "facebook-fill" },
        { key: :instagram, name: "Instagram", icon: "instagram-line" },
        { key: :youtube, name: "YouTube", icon: "youtube-line" }
      ].freeze

      def podcasts
        PODCAST_SLOTS.filter_map.with_index(1) do |podcast, index|
          image = image_url(podcast)
          next if image.blank?

          {
            key: podcast,
            name: t("decidim.content_blocks.podcast_carousel.podcast_number", number: index),
            image:,
            social_links: SOCIAL_NETWORKS.flat_map do |network|
              urls = social_urls(podcast, network[:key])
              urls.map.with_index(1) do |url, index|
                network.merge(url:, label: social_link_label(network[:name], index, urls.length))
              end
            end
          }
        end
      end

      def title
        translated_attribute(model.settings.title).presence || t("decidim.content_blocks.podcast_carousel.default_title")
      end

      private

      def image_url(podcast)
        uploader = model.images_container.attached_uploader(:"#{podcast}_image")
        uploader&.url
      end

      def setting(name)
        model.settings.public_send(name)
      end

      def social_urls(podcast, network)
        multiple_urls = setting("#{podcast}_#{network}_urls").to_s.lines
        multiple_urls.filter_map { |value| safe_social_url(value) }.uniq
      end

      def social_link_label(network_name, index, total)
        return network_name if total == 1

        "#{network_name} #{index}"
      end

      def safe_social_url(value)
        uri = URI.parse(value.to_s.strip)
        uri.to_s if uri.is_a?(URI::HTTP) && uri.host.present?
      rescue URI::InvalidURIError
        nil
      end
    end
  end
end