require 'rubygems'
require 'sane' # require_relative Array#ave
require_relative 'jruby-swing-helpers/swing_helpers'
require_relative 'jruby-swing-helpers/play_mp3_audio'
require_relative 'jruby-swing-helpers/storage'
require_relative 'create_icon_from_numbers.rb'

include SwingHelpers
  
class MainWindow < JFrame

  def set_normal_size
    set_size 250,0
  end
  
  def super_size
    unminimize
    set_size 1650,1000
    self.always_on_top=true # I think I need to redo this after each JOptionPane call for jdk6...
  end

  Storage = ::Storage.new("pomo_timer")
  Storage.set_default('all_done', [])
  
  def setup_timings
    got = SwingHelpers.get_user_input("enter your timing minutes, like 25,4,25,15", Storage['timings'])
    Storage['timings'] = got
    @timings = got.split(',').map{|min| min.to_f*60}
    @break_time = @timings.min/60
	if @timings.length > 1
      @big_break_time = @timings.uniq.sort[1]/60
	else
	  @big_break_time = @timings[0]
	end
  end

  def initialize
      super # avoid weird bugz in calling methods before proper initialization...
      set_normal_size
	    set_location 100,100
      com.sun.awt.AWTUtilities.setWindowOpacity(self, 0.8) 
      happy = Font.new("Tahoma", Font::PLAIN, 11)
      @name_label = JLabel.new
      @name_label.font = happy
      @name_label.set_bounds(44,4,1600,14)
      
      panel = JPanel.new
      @panel = panel
      panel.set_layout nil
      add panel # why can't I just slap these down?
      panel.add @name_label
  end
  
  def go
      setup_timings
      @start_time = Time.now
      cur_index = 0
      setup_pomo_name @timings[0]/60
      @switch_image_timer = javax.swing.Timer.new(500, nil) # nil means it has no default person to call when the action has occurred...
      @switch_image_timer.add_action_listener do |e|
        seconds_requested = @timings[cur_index % @timings.length]
        next_up = @timings[(cur_index+1) % @timings.length]
        seconds_left = (seconds_requested - (Time.now - @start_time)).to_i
        if seconds_left < 0
          super_size
          set_title 'done!'
		      Storage['all_done'] = Storage['all_done'] + [@real_name] # save history away for posterity... 
		      sound = PlayMp3Audio.new('diesel.mp3')
		      sound.start
          SwingHelpers.show_blocking_message_dialog "Timer done! #{seconds_requested/60}m at #{Time.now}. Next up #{next_up/60}m." 
		      sound.stop
		      minutes = next_up/60
          setup_pomo_name minutes
		      if(minutes > @break_time)
            set_normal_size
		      else
		        super_size # for breaks to force them...
		      end
          @start_time = Time.now
          cur_index += 1
		  @already_shown_on_task_question = false
        else
		  if seconds_left < seconds_requested/2 && !@already_shown_on_task_question
		    super_size
		    SwingHelpers.show_blocking_message_dialog "are you on target #{@name}?"
			set_normal_size
			@already_shown_on_task_question = true
		  end
          minutes = (seconds_left/60).to_i          
          if seconds_left > 60
            current_time = "#{minutes}m"
            icon_time = current_time # like the 'm' in there for easy glancing ability :P
          else
            current_time = "%2ds" % seconds_left
            icon_time = current_time # have the 's' in there
          end
          self.icon_image = CreateIconFromNumbers.get_letters_as_icon(icon_time, 256) # it scales down nicely
		  set_title @name + " " + current_time
          @name_label.text = @name + " " + current_time
        end
      end
      @switch_image_timer.start
      self.always_on_top=true
      show
  end
  
  def setup_pomo_name minutes
     if minutes > @break_time
  	   if minutes > @big_break_time
  	     begin
           @real_name = SwingHelpers.get_user_input("name for next pomodoro (from top of list)? #{minutes}m", Storage['real_name']) 
  		   rescue Exception => canceled
  		     SwingHelpers.hard_exit # so we don't have to shutdown timers, blah blah
  		   end
  		   Storage['real_name'] = @real_name
         @name = @real_name
  		   Thread.new { 
  		     sleep 1.0 
  		     minimize
  		   }
  	   else
  	     @name = "big break!"
  		 end
     else
       @name = "break!"
     end
  end

end

if $0 == __FILE__
  MainWindow.new.go
end