#! ruby
require 'optparse'


class JugglerFest

  def initialize 
    @filename = ""
    @outputname = ""
    @jugglerPerCircuit = 0
    # {name => "", {:h => 0, :e => 0, }}
    @jugglers = Hash.new 

    # {name => "", {:h => 0, :e => 0, :circuit => []}}
    @circuits = Hash.new 
  end

  def setFilenames (input, output)
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
    if !File.file?(@filename) and !File.readable?(@filename)
      puts "Incorrect file name or insufficient rights for " + @filename
    else
      file = File.new @filename, "r"
      begin
        self.parseAndFill(file)
      rescue
        puts "Line up generation aborted because an exception was raise!"
      end
    end
   
  end

  
  def parseAndFill(file)
    begin
      line_num = 1
      temp = Array.new
      file.readlines.each do |line|
        if line =~ (/C *\w+ *H:\d+ *E:\d+ *P:\d+ *$/)
          temp = line.split(" ")
          @circuits[temp[1]]= {:h => temp[2].split(":")[1], :e => temp[3].split(":")[1], :p => temp[4].split(":")[1]}
        elsif line =~ (/J *\w+ *H:\d+ *E:\d+ *P:\d+ *(\w+,)*\w+ *$/)
          temp = line.split(" ")
          @jugglers[temp[1]] = {:h => temp[2].split(":")[1], :e => temp[3].split(":")[1], :p => temp[4].split(":")[1], :circuit => temp[5].split(",")}
        elsif line.match(/([\w+])\n$/)
          raise "The file \"#{@filename}\" is not properly formatted\nline: #{line_num}\n\"#{line}\""
        end
      line_num += 1
      temp.clear
      end
  rescue => err
    puts "File Syntax Exception: #{err}"
    raise 
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
# lineupGenerator.setFilenames(ARGV.first.to_s, ARGV.last.to_s)
lineupGenerator.setFilenames("jugglefest.txt", "jugglefest_output.txt")
# Launch the computation
lineupGenerator.generate

puts "Lineup generation done, thanks for looking at my application :)"
