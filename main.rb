require 'gosu'
require_relative 'engine'
require_relative 'Units'
require 'logger'

class GameWindow < Gosu::Window
  def initialize
    super 1200, 600, false
    self.caption = "Shoot em up 5"
	File.delete("log.txt") if File.exist? "log.txt"
	@logger = Logger.new("log.txt")
	@logger.level = Logger::INFO
	#def initialize( x, y, vx, vy, max_speed, angle, rot_speed, window)
    @player = Player.new(20, 300, 0, 0, 90, 0, self)
	#@player.setimage("media/Player.bmp")
	@animations = Array.new # stuff that doesn't interact with anything
	@fields = Array.new # stuff that has a 1-way interaction for 1 frame. There might be a better way go at this
    @bullets = Array.new
    @enemies = Array.new #this will be merged into just objects_with_mass... maybe with some extra logic for them.
    #either way the collision checking will go for every pair on screen
	@media = Hash.new #this is for images - every object has a name and an image for that name
  end

  def update
    # TODO: get  a better player input handling - this is too clunky and ugly in general, as well as poor mem managment
    @direction = "STOP"
    if button_down? Gosu::KbW 
	  @direction = "UP"
	end
	if button_down? Gosu::KbS 
	  @direction = "DOWN"
	end
	@action = "IDLE"
	if button_down? Gosu::KbSpace
	  @action = "FIRE"
	end
	
	# TODO: this should have some random enemy spawning action as well... not sure where to put it though, but for testing purposes, this is at a high prio
	max_x = 0
	@enemies.each do |enemy|
	  max_x = enemy.x if enemy.x > max_x
	end
	
	if max_x < 1200 #@enemies.size < 10 #
	  #spawn a test enemy
	  #  def initialize( x, y, vx, vy,  angle, rot_speed, window)
	  #TODO: lookup a set of spawn patterns in a file, from there find a set of classes to spawn
	  
	  
	  @enemies << MediumEnemy.new( 1200, rand(500)+50, 0, 0, 270, 0, self)
	  #@enemies << MediumEnemy.new( 1200, rand(300)+300, 0, 0, 270, 0, self)
	  #@enemies << MediumEnemy.new( 1200, rand(300)+300, 0, 0, 270, 0, self)
	  #@enemies << MediumEnemy.new( 1200, rand(300)+300, 0, 0, 270, 0, self)
	  #@enemies << MediumEnemy.new( 1200, rand(300)+300, 0, 0, 270, 0, self)
	  @enemies << BasicEnemy.new( 1220, rand(500)+50, 0, 0, 270, 0, self)
	  
	end
	
	
	
    #@direction 
    @player.accelerate @direction
    bullets = []
    bullets << @player.move
	#@action
	if button_down? Gosu::KbSpace
	  bullets << @player.weapons[0].fire if @player.weapons[0].reloaded?
	end
	bullets.flatten!
	bullets.compact!
	@bullets << bullets unless bullets.empty?
	@bullets.flatten! #TODO: move this into def weapons fire, as not only player will fire and this looks ugly here
		
	#collision
	@bullets.each do |bullet|	  
	  @enemies.each do |enemy|
	    if (bullet.size + enemy.size)/2 > Gosu::distance(bullet.x, bullet.y, enemy.x, enemy.y)
	      bullet.collide enemy
	    end
	  end
	end
	
	@enemies.each do |enemy1|
	  @enemies.each do |enemy2|
	    if enemy1 != enemy2
	      if (enemy1.size + enemy2.size)/2 > Gosu::distance(enemy1.x, enemy1.y, enemy2.x, enemy2.y)
	        enemy1.collide enemy2
	      end
	    end
	  end
	end
	
	@bullets.each do |bullet1|
	  @bullets.each do |bullet2|
	    if bullet1 != bullet2
	      if (bullet1.size + bullet2.size)/2 > Gosu::distance(bullet1.x, bullet1.y, bullet2.x, bullet2.y)
	        bullet1.collide bullet2			
		  end
		end
	  end
	end
	
	@bullets.each do |bullet|
	  bullet.thrust
	  bullet.accelerate
	  bullet.move
	end
	@enemies.each do |enemy|
	  enemy.thrust
	  enemy.accelerate
	  enemy.move
	end
	#animations
	@animations.each do |animation|
	  #here we add -1 to the life of the animation, draw the next instance in draw
	  animation.move
	end
	#fields (quite small)
	@fields.each do |field|
		@enemies.each do |enemy|				
				field.interact_with enemy			
		end
		@bullets.each do |bullet|			
				field.interact_with bullet			
		end
		field.destroy(@animations, @fields)
	end
	
	
	@enemies.each { |enemy| enemy.damage(1) if Gosu::distance(enemy.x, enemy.y, @player.x, @player.y) < (@player.size + enemy.size)/2}
	@enemies.each do |enemy|
	 if Gosu::distance(@player.x, @player.y, enemy.x, enemy.y) <= enemy.range
	   enemy.target = @player
	   else
	   enemy.target = nil
	 end
	end
	#cleanup (killing)
	@enemies.each do |enemy| 
	  unless enemy.alive?
	    enemy.destroy(@animations, @fileds) #animations, fields. First is for visible stuff that don't do anything, second is for invisible stuff that do things
	    #this will not remove him from the array - i do not have that kind of control here
	  end
	end
	
	@bullets.each do |bullet|
	  unless bullet.alive?
	    bullet.destroy(@animations, @fields)
	  end
	end
	#more cleanup (memory)
	@bullets.select! { |bullet| bullet.alive?}	
	@enemies.select! { |enemy| enemy.alive?}
	@animations.select! { |animation| animation.alive? }
	@fields.select! { |field| field.alive? }
	#------------++++++++++++++++++-------------#
  end

  def draw	
    @player.draw @media
    @bullets.each { |bullet| bullet.draw @media}
    @enemies.each { |enemy|  enemy.draw @media}
    @animations.each {|animation| animation.draw @media }
  end
  
  def button_down(id) #TODO: move all button controls to this function
    if id == Gosu::KbEscape
      close
    end
  end
end

window = GameWindow.new
window.show
