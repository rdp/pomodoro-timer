require 'java'

module M
  include_package  'java.awt.image'; [BufferedImage]
  include_package 'java.awt'; [RenderingHints, Font, Color]
  include_package 'java.awt.font'; [TextLayout]
  include_package 'javax.swing'; [JFrame, JLabel]
  
  SIZE = 64
  ICON_DIMENSION=SIZE-5
  def self.get_letters_as_icon letters
  
  image = BufferedImage.new(SIZE,SIZE, BufferedImage::TYPE_INT_ARGB);
  graphics = g = image.createGraphics()
  g.setColor(Color::WHITE )
  g.fillRect(0,0,SIZE,SIZE)

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
      
   graphics.setFont(Font.new("Arial", Font::BOLD, ICON_DIMENSION-5));
   frc = graphics.getFontRenderContext();
   
   mLayout = TextLayout.new(letters, graphics.getFont(), frc)
   y = ICON_DIMENSION - ((ICON_DIMENSION - mLayout.getBounds().getHeight()) / 2)
   x = (ICON_DIMENSION - mLayout.getBounds().width) / 2
   graphics.setColor(Color::black);
   graphics.drawString(letters, x, y);
   image
  end

   class J < JFrame
     def initialize
       super
       self.icon_images=[M.get_letters_as_icon('09')]
     end
   end
    
end

M::J.new.show