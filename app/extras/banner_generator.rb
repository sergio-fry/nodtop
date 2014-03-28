require 'RMagick'
class BannerGenerator
  include Magick

  def self.generate(count)
    image = Image.read(File.join(Rails.root, "app/banners/banner_1.gif"))[0]


    watermark_text = Draw.new
    watermark_text.annotate(image, 0,0,0,0, "#{count}-й") do
      watermark_text.gravity = EastGravity
      self.pointsize = 13
      self.fill = "white"
      self.font_family = "Arial"
      self.font_weight = BoldWeight
      self.stroke = "none"
    end

    image.to_blob
  end
end