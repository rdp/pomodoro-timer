require 'java'

module M
  include_package  'java.awt.image'; [BufferedImage]
  include_package 'java.awt'; [RenderingHints, Font]
  include_package 'java.awt.font'; [TextLayout]
  include_package 'javax.swing'; [JFrame, JLabel]
  
  size = 14
  image = BufferedImage.new(size,size, BufferedImage::TYPE_INT_ARGB);
  graphics=g= image.createGraphics()
  g.setColor(Color::WHITE )
  g.fillRect(0,0,size,size)
   

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
      
   ICON_DIMENSION=5
   letter = '9';
   graphics.setFont(Font.new("Arial", Font::BOLD, ICON_DIMENSION-5));
   frc = graphics.getFontRenderContext();
   mLayout = TextLayout.new("" + letter, graphics.getFont(), frc);

   x = (-0.5 + (ICON_DIMENSION - mLayout.getBounds().getWidth()) / 2);
   y = ICON_DIMENSION - ((ICON_DIMENSION - mLayout.getBounds().getHeight()) / 2);
   graphics.drawString("" + letter, x, y);
   $image = image
   
  
   class J < JFrame
     def initialize
       super
       p 'set it'
       self.icon_image=$image
     end
     def go
      show
     end
   end
    
end

M::J.new.go