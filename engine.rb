class Massless_object #used for global forces, explosions and animations that do not interact with the game (although i did want a corpse to be around)
  attr_reader :x, :y, :vx, :vy, :angle, :hitpoints, :size, :window
  attr_accessor :rot_speed, :x, :y, :vx, :vy
  def initialize( x, y, vx, vy, angle, rot_speed, window)
    @x = x
	@y = y #x and y are coordinates.
	@vx = vx
	@vy = vy #speed 
	@max_speed = 100 #this is defined by instance, 100 is default
	@angle = angle #direction of next force application, weapons facing, stuff	
	@rot_speed = rot_speed	
	@window = window	
	localinit
  end
  
  def localinit
  end
   
  def draw media
  
	if @image_size == nil
		#single image
		if media[@image_location] == nil then
			#load the image
			media[@image_location] = Gosu::Image.new(@window, @image_location, false)	
			setfactors media[@image_location]
		end      
	
		#show the image from memory if it's on screen	
		if @x < 1200 && @x > -20			
			if @factor_x == nil 
				setfactors media[@image_location]
			end			
			if @show_damage == true
				ratio = (@hitpoints * 255 )/ @max_hitpoints 
				media[@image_location].draw_rot(@x, @y, 1, @angle, 0.5 , 0.5 , @factor_x, @factor_y, Gosu::Color.new(255, 255, ratio, ratio))
			else
				media[@image_location].draw_rot(@x, @y, 1, @angle, 0.5 , 0.5 , @factor_x, @factor_y)
			end
		end
		
	else
		#tiled image	
		#index = @image.size - @life / @image.size + 1 #should probably max_life here somewhere
		#@image[index].draw_rot(@x, @y, 1, @angle, 0.5 , 0.5 , @factor_x, @factor_y) if index < @image.size and index >= 0
		if media[@image_location] == nil
			#load the images
			#puts @image_location, @image_size
			media[@image_location] = Gosu::Image.load_tiles(@window, @image_location, @image_size, -1, true)
			setfactors media[@image_location][0]
		end
		
		index = @life / @image_size
				
		if @x < 1200 && @x > -20
			if @factor_x == nil
				#p @image_location
				setfactors media[@image_location][index]
			end
			
			if @show_damage == true
				ratio = (@hitpoints * 255 )/ @max_hitpoints 
				media[@image_location].draw_rot(@x, @y, 1, @angle, 0.5 , 0.5 , @factor_x, @factor_y, Gosu::Color.new(255, 255, ratio, ratio))
			else
				media[@image_location][index].draw_rot(@x, @y, 1, @angle, 0.5 , 0.5 , @factor_x, @factor_y)
			end
		end	
	end	
  end  
   
  def alive?
    @hitpoints > 0 && @life != 0
  end
  
  def setfactors image #anything that gets drawn should have this called after an image is set
    	@factor_x = @size*1.0 / image.width
		@factor_y = @size*1.0 / image.height             
  end
  
  def damage( hitpoints )
    @hitpoints -= hitpoints
  end 
   
  def move    
    if @y - @size/2 < 0 ##edge collision
	  @vy *= -1
	  @y = 0 + @size/2
	else
	  if (@y > 600 - @size/2)
	    @vy *= -1
		@y = 600 - @size/2
	  end
	end
    
    #@rot_speed = @max_rot_speed if @rot_speed > @max_rot_speed #FIXME: not correct
    #@rot_speed = -@max_rot_speed if @rot_speed < -@max_rot_speed
    
    @angle += @rot_speed
  
    @x += @vx
	@y += @vy
	
	if @ax**2 + @ay**2 == 0
	
	  @vx *= 1 - @friction #0.97
	  @vy *= 1 - @friction #0.97
	  
	end 
	@rot_speed *= 1 - 2*@friction #let's hope this works
	
	
	
	if @vx**2 + @vy**2 > (2*@max_speed)**2 + 1
	  @vx *= (1 - 10*@friction)**2
	  @vy *= (1 - 10*@friction)**2
	  #was = @hitpoints
	  
	  damage(@friction*100)
	
	end
	
	@life -= 1 unless @life.nil?
	
	@ax = @ay = 0
  end  
  
   def destroy (animations, fields)
    #animate, sound and explosion. maybe all are seperate methods that get overwritten? the explosion is definatly a seperate one    
  end
  
  def next_pos(times = 1)
    #TODO: test this function
	#this function should provide the next position of self in "times" frames of time
	next_x = @x + @vx * times
	next_y = @y + @vy * times
	return next_x,next_y
  end
   
end


class Object_with_mass < Massless_object
  attr_reader :mass, :range
  attr_accessor :target
  
  def initialize( x, y, vx, vy, angle, rot_speed, window)
    super
	@range = -1 #default blind range for stuff
	@life = -1
	@friction = 0.3 #default value
	@rot_acceleration = 0
	@mass = 10
	@size = 10	
	@max_rot_speed = 20
	@ax = 0
	@ay = 0 #this is used for less then one tick and does not need initialisation
	@hitpoints = 10		
	@angle_to_target = 0
	@target = nil #not nessesary - will travel in a straight line
	self.localinit
  end
    
  def localinit
  end
  
  def collide(other_object) #only movment pattern changes
    #depending on mass and relative speed, damage the other_object and change impulse.
	#the problem is the we have to do both damages and impule changes at the same time to avoid errors on the second run
	#or we can use a seperate method for changing collision speeds
	
	#first we count the delta speed and get a total speed vector
	speed_x = (@vx - other_object.vx)
	speed_y = (@vy - other_object.vy) # usually 0
	
	
	total_speed = ((speed_x**2) + (speed_y**2))**0.5  
	#then we count that speed's angle to the objects center. alpha is the angle by which we split the resulting force
	speedangle =   Gosu::angle(0 ,0  , speed_x       , speed_y)
	object_angle = Gosu::angle(@x, @y, other_object.x, other_object.y)
	
	alpha = Gosu::angle_diff(speedangle, object_angle)

	force_push       = Gosu::offset_y(alpha, total_speed*@mass)#*10#*(@mass/other_object.mass)*total_mass
	force_push_angle = object_angle
	
	other_object.thrust force_push_angle, -force_push/other_object.mass #force to the center of mass
	thrust force_push_angle, force_push/@mass
	
	#TODO: move damage to movement calculation - if a small force is applied, 
	damage force_push.abs
	other_object.damage force_push.abs
	
	@x = other_object.x + Gosu::offset_x( object_angle, -(@size + other_object.size + 2 )/2 )
	@y = other_object.y + Gosu::offset_y( object_angle, -(@size + other_object.size + 2 )/2 )	
		
	#also add turn force
	force_turn = Gosu::offset_x(alpha, total_speed)

	other_object.rot_speed += force_turn*other_object.size/other_object.mass
	@rot_speed             += force_turn*@size/@mass
  end
  
  def get_angle_to_target # redefine for each class that needs to go nuts
    
    if (@vx**2 + @vy**2) > @max_speed**2 #this is to slow down the unit if it's spinning too fast
        temp = Gosu::angle(0,0, @vx,@vy) - 180
        #puts "angle_to_target: #{temp}, rot_speed: #{@rot_speed}"
        temp += 360 if temp < 0
        temp -= 360 if temp > 360
        return @angle_to_target = Gosu::angle_diff(@angle, temp)     
    end
    
      return -1 #wait... what? i don't remember why i'm returning -1
  end
  
  def thrust angle = 361, force = 100500
    #default values are here just because outside forces have an angle, inside forces do not (361)
    if (get_angle_to_target.abs < 90) && angle == 361 && force == 100500
      force = @acceleration if force == 100500 #this is a very, very bad way toset default values for these things
    else
      force = 0 if force == 100500  
    end
    #puts "angle #{angle} force #{force}"
    #puts "vx: #{@vx} vy: #{@vy} maxspeed: #{@max_speed}"
    angle = @angle if angle == 361  
        
    @ax += Gosu::offset_x(angle, force)
    @ay += Gosu::offset_y(angle, force)       
  end
  
  def accelerate
    
    @vx += @ax
    @vy += @ay   
    
    #get angle to target - this will be the usual pathfinder gimmick
    #also confine angle to 0..360
    @angle += 360 if @angle < 0
    @angle -= 360 if @angle > 360    
    
    if @rot_speed.abs < @max_rot_speed
      if get_angle_to_target < 0    
        @rot_speed -= @rot_acceleration
      else
        @rot_speed += @rot_acceleration
      end
    else
      @rot_speed -= @rot_acceleration if @rot_speed > 0
      @rot_speed += @rot_acceleration if @rot_speed < 0
    end
      
    # @rot_speed += @rot_acceleration #uncomment this in another place - it should handle aiming
    #~ unless  @acceleration == nil
		#~ if (@ax**2 + @ay**2)**0.5 > @acceleration
		  #~ self.damage ((@ax**2 + @ay**2)**0.5 - @acceleration)**2
		#~ end
    #~ end
    @ax = 0
    @ay = 0
  end

  def getImpulse
    ((@vx**2 + @vy**2 )**0.5)*@mass	
  end

end

class Explosion < Massless_object
  #this class has a nice method for exploding. It will do something with all objects in range.
  #Objects are fed one by one
  #fields are also using this class
  attr_accessor :damage_radius, :force_radius
  def initialize( x, y, vx, vy, angle, rot_speed, window)
    super
    @damage = 100
    @edge_damage = 100
    
    @damage_radius = 100
    
    @force = 100
    @edge_force = 100
    
    @force_radius = 100
	
	@life = 0
  end
  
  def interact_with object
      #object must be an item with mass
      #uses damage, edge damage, damage radius
      #same for force      
      #(enemy1.size + enemy2.size)/2 > Gosu::distance(enemy1.x, enemy1.y, enemy2.x, enemy2.y)
      distance = Gosu::distance(object.x, object.y, @x, @y) - object.size
	  distance = 0 if distance < 0
	  
      if distance <= @damage_radius + object.size		      
		damage = (@damage - @edge_damage) * ((@damage_radius - distance)/@damage_radius) + @edge_damage/@damage_radius            
		object.damage(damage)
      end
      
      if distance <= @force_radius + object.size
		force = (@force) * ((@force_radius - distance)/@force_radius) + @edge_force * distance/@force_radius
		angle = Gosu::angle(@x, @y, object.x, object.y)
		object.thrust angle, force*object.size/object.mass
      end
  end
end

class Weapon
  
  def initialize (delta_x, delta_y, angle, rot_acceleration, owner)
    # we should rework this class later to make weapons just normal units with certain restrictions
    #is a weapon just a dependent Object_with_mass? maybe it's a massless object to make interactions simpler?
    @reload = 20 #frames i think
    @current_reload = 0 #this is not static... probably there is a better way of doing this
    @burst = 1 #count
    @burst_reload = 0
    @current_burst_reload = 0 #frames, not sure how to do this right, but let's leave it here as a reminder
    @angle = angle #degrees
	@rot_acceleration = rot_acceleration #deg/frame
	@max_rot_speed = 0 #max_rot_speed#deg/frame
	@max_angle = 0 #max_angle #max deviation from angle. this is to make things more fun.
	@max_spread_angle = 0
	@owner = owner #probably an Object_with_mass, but it doesn't have to be
	@relative_x = delta_x #pixels offset to owner at owners angle = 0 (looking up)
	@relative_y = delta_y #same, but other coordinate
	@image = nil #don't think bullets are animated, so this is jsut a link
	@bullet = nil#Object_with_mass with a explosion on death... i think each bullet type gets it's own class and works from there
	localinit
	@window = owner.window
  end
  
  def localinit
  end
  
  def reloaded?
    @current_reload == 0
  end
  
  def fire
    #spawn a bullet. the place to do this is harder to find then it seems
	#should also be able to use a false signal to fire a tracking shot without aiming
	#def initialize( x, y, vx, vy, angle, rot_speed, window)
	if @current_reload == 0 || (@current_burst_reload % @burst_reload == 0 && @current_burst_reload > 0)then
	    #burst times, with burst reload in between shots
	    @current_burst_reload = @burst_count * @burst_reload if @current_burst_reload == 0 && @current_reload == 0
	    @current_reload = @reload if @current_reload == 0
	    
	    tempangle = @owner.angle + @angle + rand(-@max_spread_angle..@max_spread_angle)
	    bulletspeed = 100 #actually is set in bullet init - 100 is for a nice number. might remove later
		bullet = @bullet.new(@owner.x + @relative_x, @owner.y + @relative_y, Gosu::offset_x(tempangle, bulletspeed), Gosu::offset_y(tempangle, bulletspeed), tempangle , 0, @owner.window)		
		
		
	end
	bullet
  end
  
  def reload
    @current_reload -= 1 if @current_reload > 0 
    if @current_burst_reload > 0      
      @current_burst_reload -= 1      
      if @current_burst_reload % @burst_reload == 0 && @current_burst_reload > 0
       
        bullet = fire
        
        return bullet
      end      
    end
  end
  
  def aim
    #rotate gun if possible
  end
end
