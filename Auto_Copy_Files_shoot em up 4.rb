#auto file copyer
require 'fileutils'

sleepy_time = 3.0

def mainfunc
  #File.copy('E:\Ruby\Gosu\Test', 'C:\Documents and Settings\kmar\My Documents')
  copy_with_path('E:\Ruby\Gosu\Test\test 2.rb', 'C:\Documents and Settings\kmar\My Documents\shoot em up 4.rb')
end



def copy_with_path(src, dst)
  FileUtils.mkdir_p(File.dirname(dst))
  FileUtils.cp(src, dst)
end

while true do 
   start_time = Time.now 
   mainfunc
   total_time = Time.now - start_time 
   sleep(sleepy_time - total_time) # ignoring the possibility of total_time > 1 
end 
