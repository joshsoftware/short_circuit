#In this problem we have to identify the circuit with the least weight between A and G. We cab start traversing from A and moving towards G or starting with G and moving backwards towards A
#
# The ciruit can be represted as follows assuming the flow to be in any direction.

@circuits = [
  ['A','B',50],
  ['A','D',150],
  ['B','C',250],
  ['D','C',50],
  ['B','E',250],
  ['D','F',400],
  ['C','F',100],
  ['C','E',350],
  ['F','G',100],
  ['E','G',200]

]


# Yet another representation
#@circuits = [
#  ['C','F',100],
#  ['C','E',350],
#  ['B','C',250],
#  ['D','C',50],
#  ['B','E',250],
#  ['D','F',400],
#  ['F','G',100],
#  ['E','G',200],
#  ['A','B',50],
#  ['A','D',150]
#
#]

@redundant_resistors = [] #to store all the redundant resistors
@start_node = 'A' #to store the startt node
@end_node = 'G' #to store the end node
@traversal_array = [] #to store all the possible circuits
@minimal_circuit = '' #to store the minimum resistance circuit
@minimum_total = -1 #to store the total resistance

#A recursive function that identifies all the possible circuits.
#Calculates the minimum possible circuit and stores it in @minimal_circuit.
#The function accepts three parameters in the order starting node of circuit, first node traversed and the total resistance which is 0 at the start
def all_circuits(current_node,traversed,prev_total)
  @circuits.each  do |link|
    next_node = nil
    total = prev_total
    if current_node == link[0]
      next_node = link[1]
    elsif current_node == link[1]
      next_node = link[0]
    end
    if next_node != nil
      if traversed.include? next_node
        next
      elsif next_node == @end_node
        total = total + link[2]
        if @minimum_total > total || @minimum_total == -1
          @minimum_total = total
          @minimal_circuit = traversed + next_node
        end
        puts (traversed+next_node) + " : " + total.to_s
        @traversal_array.push([traversed+next_node,total])
        next
      else
        total = total + link[2]
        all_circuits(next_node,traversed+next_node,total)
      end
    end
  end
end

all_circuits(@start_node,'A',0)

#Calculate all the redundant resistors
@circuits.each_index do |index|
  if first_occurence = @minimal_circuit.index(@circuits[index][0])
    if (first_occurence+1) == @minimal_circuit.index(@circuits[index][1])
      next
    end
  end
  @redundant_resistors.push(@circuits[index])
end


#Display the result
puts "Minimal circuit:  " +  @minimal_circuit
puts "Minimal Total:    " + @minimum_total.to_s

print "Result is --->    "
p @redundant_resistors
