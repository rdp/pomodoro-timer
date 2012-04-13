require 'java'

module CreateIconFromNumbers
  include_package  'java.awt.image'; [BufferedImage]
  include_package 'java.awt'; [RenderingHints, Font, Color]
  include_package 'java.awt.font'; [TextLayout]
  include_package 'javax.swing'; [JFrame, JLabel]
  
  def self.get_letters_as_icon letters, size=64
    letters = letters.to_s
  
  image = BufferedImage.new(size, size, BufferedImage::TYPE_INT_ARGB);
  graphics = g = image.createGraphics()
#  g.setColor(Color::WHITE )
#  g.fillRect(0,0,SIZE,SIZE)

=begin needed?  
   for (int col = 0; col < ICON_DIMENSION; col++) {
      for (int row = 0; row < ICON_DIMENSION; row++) {
         image.setRGB(col, row, 0x0);
      }
   }
=end
  
   graphics.setRenderingHint(RenderingHints::KEY_TEXT_ANTIALIASING,
      RenderingHints::VALUE_TEXT_ANTIALIAS_ON);
   graphics.setRenderingHint(RenderingHints::KEY_ANTIALIASING,
      RenderingHints::VALUE_ANTIALIAS_ON);
      
   icon_size = size-10
  
   graphics.setFont(Font.new("Arial", Font::BOLD, icon_size-5));
   frc = graphics.getFontRenderContext();
   
   mLayout = TextLayout.new(letters, graphics.getFont(), frc)
  
   y = icon_size - ((icon_size - mLayout.getBounds().getHeight()) / 2)
   x = (icon_size - mLayout.getBounds().width) / 2
   graphics.setColor(Color::red) # TODO more tomatoezy :P
   graphics.drawString(letters, x, y);
   image
  end

    
end

if $0 == __FILE__
   class J < javax.swing.JFrame
     def initialize
       super
       self.icon_images = (1..128).map {|n| CreateIconFromNumbers.get_letters_as_icon(n, n.to_i)}
     end
   end
  J.new.show
end