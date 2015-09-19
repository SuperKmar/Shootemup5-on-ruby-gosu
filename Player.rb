#  Player.rb
#  
#  Copyright 2015 Kmar <kmar@kmar-Kubuntu>
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  
#  
require_relative "engine"

class Player < Object_with_mass
  attr_reader :weapons
  def localinit
	@image_location = "Media/Ship.png"
    #@image = Gosu::Image.new(@window, @image_location, false) #image_location
    #def initialize (delta_x, delta_y, angle, rot_acceleration, owner)
    @size = 45
    @maxspeed = 10
    @weapons = []
    @weapons << PlayerWeapon.new( 10, 0, 0, 0, self)
    #setfactors
  end
   
  def accelerate(direction)
    if direction == "UP"
      @vy += -1
	else
	  if direction == "DOWN"	  
        @vy += 1
	  end
	end
  end
  
  def move
    @x += @vx
	@y += @vy
	
	@vx *= 0.9
	@vy *= 0.9
	
	if @y - @size/2 < 0
	  @vy *= -1
	  @y = 0 + @size/2
	else
	  if (@y > 600 - @size/2)
	    @vy *= -1
		@y = 600 - @size/2
	  end
	end
	bullets = []
	@weapons.each do |w|
	  b = []
	  b = w.reload 
	  #puts "imma reloading: #{b}"
	  #b.compact!
	  bullets << b unless b.nil?
	end
	  
	#p bullets unless bullets == []
	bullets
  end 
   
end


class PlayerWeapon < Weapon  
  def localinit    
    @bullet = Bullet 
    @reload = 100
    @burst_count = 3
    @burst_reload = 7
    @max_spread_angle = 2 # in degrees, double it to get arc of fire
  end  
end



class Bullet < Object_with_mass #not sure we even need this, but ok
  attr_reader :life
  
  def localinit
    @life = 300 #500
	@image_location = "Media/Bullet.png"
	#@image = Gosu::Image.new(@window, @image_location, false) #image_location
	#@vx = 10 #moved to weapon definition
	#@vy = 0
	@max_speed = 10 #7
	@acceleration = 0.001
	@hitpoints = 80 #20
	@mass = 50 #10
	@size = 4
	@friction = 0.001 #0.001
	#setfactors
	
	ratio  = @max_speed / (@vx**2 + @vy**2 )**0.5
	#ratiox = @vx*@vx.abs / ratio
	#ratioy = @vy*@vy.abs / ratio
	
	#fix these to match maxspeed in their sum
	@vx *= ratio
	@vy *= ratio #@max_speed * ratioy
	
  end
  
  def destroy(animations, fields)
    animations << BulletAnimation.new(@x, @y, @vx, @vy, @angle, @rot_speed, @window)
	fields     << Bullet_explosion.new(@x, @y, 0, 0, 0, 0, @window)
  end
  #def destroy animations, fields
	  #death_animation = BasicEnemyExplosion.new(@x, @y, @vx, @vy, @angle, @rot_speed, @window )
      #animations << death_animation
      
	  ##death_animation.sample.play
	#end
  
end

class BulletAnimation < Massless_object
   def localinit
    @hitpoints = 9001 #this is so alive? works
    @ax = @ay = 0 
    @friction = 0.03
    @mass = 10
	@max_speed = 5
	@acceleration = 0
    @size = 7
	@image_location = "Media/BulletAnimation.png"
	@image_size = -10
    #@image = Gosu::Image.load_tiles(@window, @image_location, -10, -1, true)
	#@sample = Gosu::Sample.new(@window, "Media/Explosion.wav")
	#@sample.play #this is sound, but you can guess that    
     
    @life = 25
    #setfactors
  end
  
  #def draw
    #draw this like a tiled image
  #  index = @image.size - @life / @image.size
  #  @image[index].draw_rot(@x, @y, 1, @angle, 0.5 , 0.5 , @factor_x, @factor_y) unless index >= @image.size
  #end
end


class Bullet_explosion < Explosion
  def initialize( x, y, vx, vy, angle, rot_speed, window)
    super
    @damage = 1
    @edge_damage = 1
    @damage_radius = 1
    
    @force = 10
    @edge_force = 10
    @force_radius = 30
	
	@life = 1
	@hitpoints = 1
  end
  def destroy( animations, fields )
    @life = 0
  end
  
end
