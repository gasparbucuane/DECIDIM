Rails.application.config.after_initialize do
  next if Decidim.content_blocks.for(:homepage).any? { |block| block.name == :podcast_carousel }

  Decidim.content_blocks.register(:homepage, :podcast_carousel) do |content_block|
    content_block.cell = "decidim/content_blocks/podcast_carousel"
    content_block.settings_form_cell = "decidim/content_blocks/podcast_carousel_settings_form"
    content_block.public_name_key = "decidim.content_blocks.podcast_carousel.name"

    content_block.images = (1..20).map do |index|
      { name: format("podcast_%02d_image", index).to_sym, uploader: "Decidim::ImageUploader" }
    end

    content_block.settings do |settings|
      settings.attribute :title, type: :text, translated: true, default: { pt: "Podcasts" }

      (1..20).each do |index|
        podcast = format("podcast_%02d", index)
        settings.attribute :"#{podcast}_name", type: :string

        [:whatsapp, :facebook, :instagram, :youtube].each do |network|
          settings.attribute :"#{podcast}_#{network}_urls", type: :text
        end
      end
    end
  end
end