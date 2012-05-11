#! ruby
require 'optparse'


class JugglerFest

  def initialize 
    @filename = ""
    @outputname = ""
    @jogglerPerCircuit = 0
  end

  def setFilename (input, output)
    @filename = input
    @outputname = output
  end

  # dot product of 3 dimension arrays x and y
  # result is typed in float
  def dotProduct(x, y)
    res = 0.0
    x.each_index { |i|
      res += x[i].to_f * y[i].to_f
    }
    return res
  end


  # Generate the lineup
  # parse, fill the data structures, then compute dot products
  # Compute line up and pretty print the output
  def generate
    if !File.file? @fileName and !File.readable? @fileName
      puts "Incorrect file name or insufficient rights for " + @fileName
    else
      file = File.new @filename, "r"
      self.parseAndFill(file)
      
    end
   
  end

  
  def parseAndFill(file)
    begin
      file.readlines.each do |line|
        puts line
      end
    end
  rescue => err
    puts "Exception: #{err}"
    err
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

lineupGenerator = JugglerFest.new


# Set input file and output file name
lineupGenerator.setFilenames(ARGV.first, ARGV.last)
# Launch the computation
lineupGenerator.generate

puts "Lineup generation done, thanks for looking at my application :)"
