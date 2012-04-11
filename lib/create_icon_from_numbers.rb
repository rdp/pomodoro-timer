require 'java'

module CreateIconFromNumbers
  include_package  'java.awt.image'; [BufferedImage]
  include_package 'java.awt'; [RenderingHints, Font, Color]
  include_package 'java.awt.font'; [TextLayout]
  include_package 'javax.swing'; [JFrame, JLabel]
  
  SIZE = 64 # doesn't seem to matter...
  
  def self.get_letters_as_icon letters
    letters = letters.to_s
  
  image = BufferedImage.new(SIZE,SIZE, BufferedImage::TYPE_INT_ARGB);
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
      
   icon_size = SIZE-10
  
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
       self.icon_images=[CreateIconFromNumbers.get_letters_as_icon('09')]
     end
   end
  J.new.show
end