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
require_relative "BasicEnemy"

class MediumEnemy < BasicEnemy
	#make a semi-init method that doesn't blow up'
	def localinit
		@rot_acceleration = 0.03
		@mass = 500
		@size = 40
		@max_rot_speed = 0.3
		@acceleration = 0.005
		@friction = 0.01
		@max_hitpoints = @hitpoints = 1000
		@max_speed = 50
		@image_location = "Media/MediumEnemy.png"
		#@image = Gosu::Image.new(@window, @image_location, false)
		#setfactors
		@range = 350
		@show_damage = true
	end
	
	def destroy animations, fields
	  death_animation = MediumEnemyExplosion.new(@x, @y, @vx, @vy, @angle, @rot_speed, @window )
      animations << death_animation	  
	end
end

class MediumEnemyExplosion < BasicEnemyExplosion
  def localinit
    @hitpoints = 9001 #this is so alive? works
    @ax = @ay = 0 
    @friction = 0.05
    @mass = 500
	@max_speed = 2
	@acceleration = 0
    @size = 65
	@image_location = "Media/MediumEnemyExplosion.png"
	@image_size = -12
    #@image = Gosu::Image.load_tiles(@window, @image_location, -12, -1, true)
	@sample = Gosu::Sample.new(@window, "Media/Explosion.wav")
	@sample.play #this is sound, but you can guess that    
     
    @life = 100
    #setfactors
  end  
  
end
