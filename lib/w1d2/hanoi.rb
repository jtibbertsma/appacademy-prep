class HanoiError < Exception
end

class TowersOfHanoi
  attr_accessor :tower1
  attr_accessor :tower2
  attr_accessor :tower3
  
  def initialize
    @tower1 = [6,5,4,3,2,1]
    @tower2 = []
    @tower3 = []
  end
  
  def win?
    @tower2.length == 6 || @tower3.length == 6
  end
  
  def tower_chooser(tower)
    if tower == 0
      @tower1
    elsif tower == 1
      @tower2
    elsif tower == 2
      @tower3
    else
      fail HanoiError.new("Wrong tower")
    end
  end
    
  def move(from, to)
    from_tower = tower_chooser(from)
    to_tower = tower_chooser(to)
    fail HanoiError.new("Empty tower") if from_tower.empty?
    item = from_tower[-1]
    fail HanoiError.new("Bad move") if item > (to_tower[-1] || 6)
    to_tower << from_tower.pop
  end
  
  def print_tower(tower)
    
    tower.reverse.each_with_index do |disk, num|
      print ' ' * (4 - num)
      puts '=' * ((disk*2) -1)
    end
  end
  
  
  
  def print_all
    [@tower1, @tower2, @tower3].each_with_index do |t,i|
      puts "Tower #{i+1}"
      puts
      print_tower(t)
      
    end
  end
        
end

t = TowersOfHanoi.new

  until t.win?
    puts "Enter the tower to move from ex.(1,2,3)"
    input = gets.chomp
    puts "Enter the tower to move to ex.(1,2,3)"
    output = gets.chomp
    
    begin
      t.move(input.to_i - 1, output.to_i - 1)
    rescue HanoiError => e
      puts e
    end
    t.print_all
    
    #t.tower1 = []
    #t.tower3 = [6,5,4,3,2,1]
  
    
  end
  puts "Congrats you win!"

 
#      =
#     ===
#    =====
#   =======