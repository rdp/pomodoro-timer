require 'java'

module CreateIconFromNumbers
  include_package  'java.awt.image'; [BufferedImage]
  include_package 'java.awt'; [RenderingHints, Font, Color]
  include_package 'java.awt.font'; [TextLayout]
  include_package 'javax.swing'; [JFrame, JLabel]
  
  def self.assign_icons_to_jframe jframe, title_bar_text, group_icon_and_alt_tab_icon_text
    jframe.icon_images = [get_letters_as_icon(title_bar_text, 20), get_letters_as_icon(group_icon_and_alt_tab_icon_text, 40)]
  end
  
  def self.get_letters_as_icon letters, size
    letters = letters.to_s
  
    image = BufferedImage.new(size, size, BufferedImage::TYPE_INT_ARGB);
    graphics = g = image.createGraphics
  
=begin needed?  
  #  g.setColor(Color::WHITE )
  #  g.fillRect(0,0,SIZE,SIZE)

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
	   icon_numbers = (1..128).map{|n| n}.reverse
       self.icon_images = icon_numbers.map {|n| CreateIconFromNumbers.get_letters_as_icon(n, n.to_i)}
     end
   end
  a = J.new
  a.show
  CreateIconFromNumbers.assign_icons_to_jframe a, 'title_bar_text', 'group_icon_and_alt_tab_icon_text'

end