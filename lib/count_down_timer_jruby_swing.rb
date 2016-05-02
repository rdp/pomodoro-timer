require 'rubygems'
require 'sane' # require_relative Array#ave
require_relative '../vendor/jruby-swing-helpers/lib/swing_helpers'
require_relative '../vendor/jruby-swing-helpers/lib/play_mp3_audio'
require_relative '../vendor/jruby-swing-helpers/lib/storage'
require_relative 'create_icon_from_numbers.rb'

include SwingHelpers
  
#JFrame.setDefaultLookAndFeelDecorated(true) # allow opacity in windows 7 -- not enough on mac?
class MainWindow < JFrame

  def set_normal_size
    set_size 250,0
    self.always_on_top=true # I think I need to redo this after each JOptionPane call for jdk6...
    if $VERBOSE
      puts "setting normal size"
    end
  end
  
  def super_size_blocking_screen
    unminimize # restore
    set_size 1650,1000
    p 'setting it large and always on top'
    self.always_on_top=true # I think I need to redo this after each JOptionPane call for jdk6...
  end

  Storage = ::Storage.new("pomo_timer")
  Storage.set_default('all_done', [])
  
  def setup_timings_once
    timings = Storage['timings'] ||= ['25','4','25','15']
    got_minutes = SwingHelpers.get_user_input("Enter your timing minutes, like 25, 4, 25, 4, 25, 15 for 3x25 minute pomodoros, with 4 minute breaks, and a 15 minute long break [must be small break < large break < pomo]\nor a single number for repated countdown timer", Storage['timings'].join(', '))
    Storage['timings'] = got_minutes.split(',').map{|n| n.strip}
    @timings_seconds = got_minutes.split(',').map{|minute| minute.to_f*60}
    @break_time = @timings_seconds.min/60 # break time is smallest number
    if @timings_seconds.length > 1
      # median  should be big break
      unique_times = @timings_seconds.uniq.sort
      @big_break_time_minutes = unique_times[(unique_times.length-1)/2]/60 # convert back to minutes
    else
      @big_break_time_minutes = @timings_seconds[0] / 60
    end
    if @big_break_time_minutes * 60 > @timings_seconds[0]
      raise "big break time seems to not be following pattern, double check pattern" # if we don't raise here it never shows the initial window somehow [?] XXXX
    end
  end

  def initialize
      super # avoid weird bugz in calling methods before proper initialization...
      #frame.setDefaultCloseOperation(JFrame::EXIT_ON_CLOSE) <sigh>
      set_normal_size
      set_location 100,100
      set_undecorated true # allow opacity mac
      com.sun.awt.AWTUtilities.setWindowOpacity(self, 0.8) 
      happy = Font.new("Tahoma", Font::PLAIN, 11)
      @name_label = JLabel.new
      @name_label.font = happy
      @name_label.set_bounds(44,4,1600,14)
      
      @panel = JPanel.new
      @panel.set_layout nil
      add @panel # why can't I just slap these down? oh well...
      @panel.add @name_label
      after_closed {
        SwingHelpers.hard_exit! # ignore those extra timers, blah blah XXXX close timers right :|
      }
  end
  
  def go
      setup_timings_once
      @cur_index = -1
      handle_done_with_current 0 # setup :)
      @start_time = Time.now
      @switch_image_timer = javax.swing.Timer.new(500, nil) # nil means it has no default person to call when the action has occurred...
      @switch_image_timer.add_action_listener { |e|
	if File.exist? 'debug_now'
	  require 'rubygems'; require 'ruby-debug'; debugger
	end
        seconds_requested = @timings_seconds[@cur_index % @timings_seconds.length]
        seconds_left = (seconds_requested - (Time.now - @start_time)).to_i
        if seconds_left < 0
          handle_done_with_current seconds_requested
        else
          update_current_icon_with_current_time seconds_left, seconds_requested		 
        end
      }
      @switch_image_timer.start
      self.always_on_top=true
      show
  end
  
  def update_current_icon_with_current_time seconds_left, seconds_requested
      minutes_left = seconds_left/60
      # half time double check popup:
      if (seconds_left < seconds_requested/2) && !@already_shown_on_task_question && !am_in_little_break?(minutes_left)
        set_normal_size
        SwingHelpers.show_blocking_message_dialog "half-time check: are you on target for (#{@name})? [also working for work?]"
        set_normal_size # ??
        @already_shown_on_task_question = true
      end
      if seconds_left > 99 # more than two digits worth of seconds, so use minutes :)
        current_time = "#{minutes_left.to_i}m"
        icon_time = current_time # like the 'm' in there for easy glancing ability :P
      else
        current_time = "%2ds" % seconds_left
        icon_time = current_time # have the 's' in there
      end
      self.icon_image = CreateIconFromNumbers.get_letters_as_icon(icon_time, 128) # it auto scales it down for us
      if OS.mac?
        com.apple.eawt.Application.getApplication().setDockIconImage self.icon_image # http://stackoverflow.com/questions/11253772/setting-the-default-application-icon-image-in-java-swing-on-os-x :|
      end
      set_title current_time + " " + @name
      @name_label.text = @name + " " + current_time + "/#{seconds_requested/60}m"
      if $VERBOSE
        puts "updated icon to #{@name_label.text}"
      end
  end

  def handle_done_with_current seconds_requested
      set_normal_size
      next_up = @timings_seconds[(@cur_index+1) % @timings_seconds.length]
      if seconds_requested > 0
        set_title 'done!'
        Storage['all_done'] = Storage['all_done'] + [@real_name] # save history away for posterity... 
        sound = PlayMp3Audio.new(File.dirname(__FILE__) + '/diesel.mp3')
        sound.start
        SwingHelpers.show_blocking_message_dialog "Timer done! (#{@name}) #{seconds_requested/60}m at #{Time.now}. Next up #{next_up/60}m." 
        sound.stop
      end # else its just setup...
      next_minutes = next_up/60
      setup_pomo_name next_minutes
      @start_time = Time.now
      @cur_index += 1
      @already_shown_on_task_question = false # reset
      if am_in_little_break?(next_minutes)
        set_normal_size
      else
        super_size_blocking_screen # for breaks to force them...
      end
      if am_in_big_break? next_minutes
        super_size_blocking_screen # force breaks...
      end
  end

  def am_in_big_break? minutes
    minutes == @big_break_time_minutes || @real_name == 'break'
  end
  
  def am_in_little_break? minutes
    minutes < @big_break_time_minutes
  end
    
  def setup_pomo_name minutes
     if minutes >= @break_time
  	 if !am_in_big_break?(minutes)
  	   begin
             @real_name = SwingHelpers.get_user_input("name for next pomodoro (from top of list)? #{minutes}m", Storage['real_name'])
  	   rescue Exception => canceled
	     puts "exiting...#{canceled}" 
  	     close # why?
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
       @name = "little break!"
     end
  end
  if $VERBOSE
    puts "set name to #{@name}"
  end
end

if $0 == __FILE__
  MainWindow.new.go
end
