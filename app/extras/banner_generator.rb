require 'RMagick'
class BannerGenerator
  include Magick

  TYPE_BLACK = 1
  TYPE_ORANGE = 2

  TYPE_TEXT_COLOR = {
    TYPE_BLACK => "#ed7500",
    TYPE_ORANGE => "#000000",
  }

  def self.generate(count, type=1)
    image = Image.read(File.join(Rails.root, "app/banners/banner_#{type}.gif"))[0]

    watermark_text = Draw.new
    watermark_text.annotate(image, 0,0,2,0, "#{count}-й") do
      watermark_text.gravity = EastGravity
      self.pointsize = 13
      self.fill = TYPE_TEXT_COLOR[type]
      self.font_family = "Arial"
      self.font_weight = BoldWeight
      self.stroke = "none"
    end

    image.to_blob
  end
end
