#  BasicEnemy.rb
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

class BasicEnemy < Object_with_mass
	#make a semi-init method that doesn't blow up'
	def localinit
		@rot_acceleration = 0.05
		@mass = 300
		@size = 25
		@max_rot_speed = 1
		@acceleration = 0.01
		@friction = 0.01
		@max_hitpoints = @hitpoints = 300
		@max_speed = 10
		@range = 600
		@image_location = "Media/BasicEnemy.png"
		#@image = Gosu::Image.new(@window, @image_location, false)
		#setfactors
		@show_damage = true
		
	end
	
	def destroy animations, fields
	  death_animation = BasicEnemyExplosion.new(@x, @y, @vx, @vy, @angle, @rot_speed, @window )
      animations << death_animation
      
	  #death_animation.sample.play
	end
	
	def get_angle_to_target # redefine for each class that needs to go nuts    
		highspeed = super
    
		if highspeed == -1 
			temp = 270
			if @x < 600 and @target != nil then #we should actually jsut set a target here, but gonna hardcode this for now
				temp = Gosu::angle(@x,@y, @target.x, @target.y)
			end
			highspeed = temp      
		end
		Gosu::angle_diff(@angle, highspeed)   #bad name for the var, as it was temporary... TODO: fox var name to something more sensable
	end
end

class BasicEnemyExplosion < Massless_object
  def localinit
    @hitpoints = 9001 #this is so alive? works
    @ax = @ay = 0 
    @friction = 0.05
    @mass = 200
	@max_speed = 2
	@acceleration = 0
    @size = 30
	@image_location = "Media/BasicEnemyExplosion.png"
	@image_size = -10	
    #@image = Gosu::Image.load_tiles(@window, @image_location, -10, -1, true)
	@sample = Gosu::Sample.new(@window, "Media/Explosion.wav")
	@sample.play #this is sound, but you can guess that    
     
    @life = 60
    #setfactors
  end
  
  #def draw media
    #draw this like a tiled image    
	#	index = @image.size - @life / @image.size + 1 #should probably max_life here somewhere
	#	@image[index].draw_rot(@x, @y, 1, @angle, 0.5 , 0.5 , @factor_x, @factor_y) if index < @image.size and index >= 0
	
#  end
end
