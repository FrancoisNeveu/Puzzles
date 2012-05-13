#! ruby
require 'optparse'


class JugglerFest

  def initialize 
    @filename = ""
    @outputname = ""
    @jugglerPerCircuit = 0
    # {:name => {:h => 0, :e => 0, }}
    @jugglers = Hash.new 

    # {:name =>  {:h => 0, :e => 0, :circuit => []}}
    @circuits = Hash.new 

    # {:circuit_ name => [:name1, :name2,..]}}
    @matchs = Hash.new
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
    #  begin
        self.parseAndFill(file)
        self.fillMatches
        self.generateOutput
     # rescue
       # puts "Line up generation aborted because an exception was raised!"
      #end
    end
   
  end

  # compute the lineup
  def fillMatches 
    @jugglers.each do |k, v|
      circuits = v[:circuits]
      keys = circuits.keys
      puts "========== KEY =========="
      p keys
      i = 0
      while i < keys.count
        if @matchs[keys[i]].nil?
          @matchs[keys[i]] = Array.new()
          @matchs[keys[i]]  = @matchs[keys[i]] << [k, @jugglers[k][:circuits][keys[i]]]
        elsif @matchs[keys[i]].count < @jugglerPerCircuit
          @matchs[keys[i]] = @matchs[keys[i]] << [k, @jugglers[k][:circuits][keys[i]]]
          p @matchs
          puts "Still place in array"
        else
            puts "non more place"
           p @matchs
           ar = @matchs[keys[i]]
           ar.sort_by! {|x, y| y <=> x[1]}
           @matchs[keys[i]] = ar
           p @matchs
            array_size =  @matchs[keys[i]].count
          if @matchs[keys[i]][array_size - 1][1] < circuits[keys[i]] 
            @matchs[keys[i]][array_size - 1][1] = circuits[keys[i]]
          end
        end
      i = i + 1
      end 
      puts "player #{k.inspect} treated || @matchs : #{@matchs}"
    end
  end


  def generateOutput
    file  = File.new( @outputname, "w")
    @matchs.each do |k, v|
      line = ""
      line = k.to_s + " "
      v.each do |name, value|
        line += name.to_s + " "
        i = 1
        @jugglers[name][:circuits].each { |c_name, dot|
          line += c_name.to_s + ":" + dot.to_i.to_s
          if i < @jugglers[name][:circuits].length
            line += " "
          elsif !(name == v.last[0])
            line += ", "
          end
          i = i + 1
         }
      end
      puts line
    end
  end

  def parseAndFill(file)
    begin
      line_num = 1
      temp = Array.new
      file.readlines.each do |line|
        if line =~ (/C *\w+ *H:\d+ *E:\d+ *P:\d+ *$/)
          temp = line.split(" ")
          @circuits[temp[1].to_sym]= {:h => temp[2].split(":")[1], :e => temp[3].split(":")[1], :p => temp[4].split(":")[1]}
        elsif line =~ (/J *\w+ *H:\d+ *E:\d+ *P:\d+ *(\w+,)*\w+ *$/)
          temp = line.split(" ")
          p_name = temp[1].to_sym
          @jugglers[p_name] = {:h => temp[2].split(":")[1], :e => temp[3].split(":")[1], :p => temp[4].split(":")[1], :circuits => {}}
          
          # iterate the circuit array and compute match 
          # score to store it with each circuit
          temp[5].split(",").each { |c|
            name = c.to_sym
            x = [@jugglers[p_name][:h], @jugglers[p_name][:e], @jugglers[p_name][:p]]
            y = [@circuits[name][:h], @circuits[name][:e], @circuits[name][:p]]
            @jugglers[p_name][:circuits][c.to_sym] =  dotProduct(x, y)
          }
        elsif line.match(/([\w+])\n$/)
          raise "The file \"#{@filename}\" is not properly formatted\nline: #{line_num}\n\"#{line}\""
        end
      line_num += 1
      end
  rescue => err
    puts "File Syntax Exception: #{err}"
    raise 
  end
  @jugglerPerCircuit = @jugglers.count / @circuits.count
  p @jugglers
  p @circuits
  puts "#{@jugglerPerCircuit} jugglers per circuit detected."
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
