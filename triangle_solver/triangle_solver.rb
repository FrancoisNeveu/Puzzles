#! ruby
require 'optparse'

class TriangleSolver
# set filename path

  def initialize
    # Current[0] = position
    # Current[1] = value
    @current = Array.new(2)
    
    # Value of the maximum
    @value = 0 
  end
  
  def getValue
    return @value
  end
  # (String) FileName = the name of the file to parse
  def setFileName(fileName)
    @fileName = fileName
  end
  
  def max (v1, v2)
    if v1 == v2
      puts "Two possible ways, taking the first one as default."
      v1
    end
    if v1 > v2
      v1
    else 
      v2 
    end
  end
    
  # clear all variables
  def clear
    @current.clear
    @value = 0
    @fileName = ''
  end
  
  # solve an file
  def solve
    if !File.file? @fileName and !File.readable? @fileName
      puts "Incorrect file name or insufficient rights for " + @fileName
    else
      begin
        # Open the file Read-only
        file = File.new(@fileName, "r");
        i = 1
        while (line = file.gets)
          lineArray = line.split(" ")
          if (lineArray.count == 1)
            @current[0] = 0
            @current[1] = lineArray[0].to_i
          else
            maximum = max(lineArray[@current[0]].to_i, lineArray[@current[0] + 1].to_i)
            if maximum.equal? (lineArray[@current[0] + 1].to_i)
              @current[0] +=  1
            end
            @current[1] = maximum
          end
          @value += @current[1]
        end
        # Close the file descriptor 
        file.close
      rescue => err
        puts "Exception: #{err}"
        err
      end
    end
  end
end

# Will hold the options parsed from comand line
options = {}

optparse = OptionParser.new do |opts|
  # Help screen
  opts.banner = "Triangle Solver V0.1, proudly made by Francois Neveu"
  opts.banner += " for Yodle :)\nTake a look at my resume  http://linkd.in/K6rv0T\n"
  opts.banner += "Usage: triangle_solver.rb options File1 File2 ..."
  
  # This displays the help screen
  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end

optparse.parse!

solver = TriangleSolver.new

# Iteration trough command line parameters
ARGV.each do |f|
  puts "Calculating the maximum total for the triangle " + f
  solver.setFileName(f)
  result = solver.solve
  puts "The maximum total for the triangle " + f + " is " + solver.getValue.to_s
  solver.clear
end

puts "Solving done, thanks for looking at my application :)"
