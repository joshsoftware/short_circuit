############
#Class Hash#
############
#Dijkstra's algorythm requires a priority queue, the easiest way to make one is to add a method
#to hash that pops the key/value pair with the lowest value.
class Hash
  #Return the key/value pair with the lowest value as an array, deletes the pair.
  def pop_lowest_value!
    smallest_pair = self.min{ |a,b| a[1] <=> b[1]}
    self.delete(smallest_pair[0]) if smallest_pair
    smallest_pair
  end
end


#############
#Class Graph#
#############
#A graph is represented as a collection of Edges, an edge representing the relationship between a pair of vertices. 
#This implementation assumes the Graph is connected ie. every vertex can be reached from every other vertex by 
#some collection of edges. Failure to supply a graph structure that follows this rule will most likely cause spurious 
#results, or more likely, outright failures.
#
#A Graph is instanciated with a array of arrays, where each internal array is a tupple representing an edge in the 
#form ["name of vertex a", "name of vertex b", distance]
#
#After the dijkstra method has been run on the graph, for any given end vertex you can print the shortest path, 
#print the set of unused edges, or return a set of the unused edges as an array similar to the input of Graph.new. 
#
#Usage:
#edges = [
#      [ "A", "B", 50],
#      [ "A", "D", 150],
#      [ "B", "C", 250],
#      [ "B", "E", 250],
#      [ "C", "E", 350],
#      [ "C", "D", 50],
#      [ "C", "F", 100],
#      [ "D", "F", 400],
#      [ "E", "G", 200],
#      [ "F", "G", 100],
#    ]
#graph = Graph.new edges 
#graph.dijkstra "A"
#graph.print_shortest_path "G"
#graph.print_unused_edges "G"
#graph.unused_edges_as_array "G"
#
class Graph
  #Edge data structure, represents an edge in a graph
  Edge = Struct.new(:vertices, :distance)

  #Builds the underlying datastructures required to process a graph.
  def initialize edges
    #The edges in this graph
    @edges = []
    
    edges.each do |e|
      @edges << Edge.new([e[0], e[1]], e[2])
    end
    puts "The following edges make up the full graph:"
    print_edges_as_array @edges
  end
  
  #Runs Dijkstra's algorythm on the graph to generate the least cost tree(@previous)
  def dijkstra start
    puts "Generating least cost tree from vertex #{start}."
    @previous = {} #The least cost tree generated by Dijkstra's algorythm
    @final_distances = {} #The hash of final distances to all vertices after running Dijkstra's algorythm
    queue = {}    #The queue of verticies to process
    queue[start] = 0
    #The actual algorythm
    while !queue.empty? do
      vertex, distance = *queue.pop_lowest_value!
      @final_distances[vertex] = distance
      get_neighbors(vertex).each do | neighbor |
        next if @final_distances.has_key? neighbor
        distance_to_neighbor = @final_distances[vertex] + get_edge(vertex, neighbor).distance
        if (queue[neighbor].nil? or distance_to_neighbor < queue[neighbor]) then
          queue[neighbor] = distance_to_neighbor
          @previous[neighbor] = vertex
        end
      end
    end
  end
  
   #Returns (as an Array of Arrays) the set of unused Edges for any given end vertex
  def unused_edges_as_array finish
    unused_edges(finish).inject([]) do |memo, edge|
      memo << [edge.vertices[0], edge.vertices[1], edge.distance]
    end
  end
  
  #Prints the unused edges with nice formating
  def print_unused_edges finish
    puts "The following edges are unused:"
    print_edges_as_array unused_edges(finish)
  end
  
  #Prints the shortest path with nice formating
  def print_shortest_path finish
    puts "The shortest path to #{finish} is:"
    puts shortest_path(finish).join("->")
  end
  
  #################
  #Private Methods#
  #################
  private
  
  #Prints an array of Edges with the Array formatting used on Ruby Learning's RPCFN
  def print_edges_as_array edges
    puts "["
    edges.each do |edge|
      puts "  [ \"#{edge.vertices[0]}\", \"#{edge.vertices[1]}\", #{edge.distance}, ]\n"
    end
    puts "]"
    
    edges.collect{|edge| edge.vertices[0] + edge.vertices[1]}
  end
  
  #Returns (as an Array of Edge objects) the set of unused Edges for any given end vertex
  def unused_edges finish
    used_edges = []
    #find all the used edges
    current_vertex = finish
    while @previous[current_vertex]
      edge = get_edge current_vertex, @previous[current_vertex]
      used_edges << edge
      current_vertex = @previous[current_vertex]
    end
    #find the unused edges
    @edges.select{ |e| ! used_edges.include? e }
  end
  
  #Returns an Array of vertex names (as Strings) representing the shortest path to finish
  def shortest_path finish
    path = []
    current_vertex = finish
    path << current_vertex
    while @previous[current_vertex]
      path << @previous[current_vertex]
      current_vertex = @previous[current_vertex]
    end
    path.reverse
  end
  
  #Returns the Edge joining vertex_a and vertex_b
  def get_edge vertex_a, vertex_b
    @edges.select{ |e| (e.vertices.include? vertex_a) && (e.vertices.include? vertex_b) }.first
  end
  
  #Returns an Array of names (as Strings) of verticies neighboring the given vertex
  def get_neighbors vertex
    @edges.inject([]) do |neighbors, edge|
      neighbors.push(edge.vertices.reject{ |v| v == vertex }) if edge.vertices.include? vertex
      neighbors.flatten
    end.uniq
  end
end


# edited the following for auto_test by ashbb
$test0 =<<EOS
@end_node = 'G'
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
EOS

$test1 =<<EOS
@end_node = 'H'
@circuits = [
   [ 'A', 'B', 50],
   [ 'A', 'D', 150],
   [ 'B', 'C', 250],
   [ 'B', 'E', 250],
   [ 'C', 'E', 350],
   [ 'C', 'D', 50],
   [ 'C', 'F', 100],
   [ 'E', 'H', 200],
   [ 'F', 'H', 100],
   [ 'D', 'G', 350],
   [ 'G', 'F', 50],
   [ 'C', 'G', 30]
]
EOS

$test2 =<<EOS
@end_node = 'D'
@circuits = [
   [ 'A', 'B', 10],
   [ 'A', 'C', 100],
   [ 'A', 'D', 100],
   [ 'B', 'C', 10],
   [ 'B', 'D', 100],
   [ 'C', 'D', 10]
]
EOS

$test3 =<<EOS
@end_node = 'G'
@circuits = [
   [ 'A', 'B', 10],
   [ 'A', 'C', 100],
   [ 'A', 'D', 100],
   [ 'B', 'C', 10],
   [ 'B', 'D', 100],
   [ 'C', 'D', 10],
   [ 'B', 'E', 10],
   [ 'C', 'F', 10],
   [ 'D', 'G', 10]
]
EOS

def bridge_method test
  eval test
  graph = Graph.new @circuits
  graph.dijkstra "A"
  graph.print_shortest_path @end_node
  graph.print_unused_edges @end_node
  graph.unused_edges_as_array(@end_node).collect{|a, b,| a + b}
end



=begin

##################
#Class GraphTests#
##################
require 'test/unit'
require 'stringio'

class GraphTests < Test::Unit::TestCase
  def setup
    @default_graph_edges ||= [
      [ "A", "B", 50],
      [ "A", "D", 150],
      [ "B", "C", 250],
      [ "B", "E", 250],
      [ "C", "E", 350],
      [ "C", "D", 50],
      [ "C", "F", 100],
      [ "D", "F", 400],
      [ "E", "G", 200],
      [ "F", "G", 100],
    ]
    @easy_graph_edges ||= [
      [ "A", "B", 50]
    ]
    @circular_graph_edges ||= [
      [ "A", "B", 50 ],
      [ "B", "C", 50 ],
      [ "C", "D", 50 ],
      [ "D", "E", 50 ],
      [ "E", "F", 50 ],
      [ "F", "A", 50 ],  
    ]
  end
  
  def test_default_graph
    start = "A"
    finish = "G"    
    expected = [
      [ 'A', 'B', 50 ],
      [ 'B', 'C', 250],
      [ 'B', 'E', 250],
      [ 'C', 'E', 350],
      [ 'D', 'F', 400],
      [ 'E', 'G', 200],
    ]
    run_unused_edge_test @default_graph_edges, start, finish, expected
  end
  
  def test_easy_graph
    start = "A"
    finish = "B"
    expected = []
    capture_console do #suppres the console chatter
      run_unused_edge_test @easy_graph_edges, start, finish, expected
    end
  end
  
  def test_circular_graph
    start = "A"
    finish = "E"
    expected = [
      [ "A", "B", 50 ],
      [ "B", "C", 50 ],
      [ "C", "D", 50 ],
      [ "D", "E", 50 ],
    ]
    capture_console do #suppres the console chatter
      run_unused_edge_test @circular_graph_edges, start, finish, expected
    end
  end
  
  def test_print_methods_for_default_graph
    start = "A"
    finish = "G"
    expected = "The shortest path to #{finish} is:\n" + 
              "A->D->C->F->G\n" + 
              "The following edges are unused:\n" +
              "[\n" +
              "  [ \"A\", \"B\", 50, ]\n" +
              "  [ \"B\", \"C\", 250, ]\n" +
              "  [ \"B\", \"E\", 250, ]\n" +
              "  [ \"C\", \"E\", 350, ]\n" +
              "  [ \"D\", \"F\", 400, ]\n" +
              "  [ \"E\", \"G\", 200, ]\n" +
              "]\n"
    run_print_test @default_graph_edges, start, finish, expected
  end
  
  def test_print_methods_for_easy_graph
    start = "A"
    finish = "B"
    expected = "The shortest path to #{finish} is:\n" +
              "A->B\nThe following edges are unused:\n" +
              "[\n" +
              "]\n"
    run_print_test @easy_graph_edges, start, finish, expected
  end
  
  def test_print_methods_for_circular_graph
    start = "A"
    finish = "E"
    expected = "The shortest path to #{finish} is:\n" + 
              "A->F->E\n" + 
              "The following edges are unused:\n" +
              "[\n" +
              "  [ \"A\", \"B\", 50, ]\n" +
              "  [ \"B\", \"C\", 50, ]\n" +
              "  [ \"C\", \"D\", 50, ]\n" +
              "  [ \"D\", \"E\", 50, ]\n" +
              "]\n"
    run_print_test @circular_graph_edges, start, finish, expected
  end
    
  #Tests the addition to Hash that pops the key/value pair with the lowest value
  def test_pop_lowest_value
    hash = {}
    hash["highestvalue"] = 100
    hash["smallestvalue"] = 0
    hash["middlevalue"] = 50
    expected = "smallestvalue"
    actual, value = *hash.pop_lowest_value!
    assert_equal expected, actual
  end  
  
  #################
  #Private Methods#
  #################
  private
  #Given the parameters of the test and a set of edges, generates the graph and tests the unused edges are correct
  def run_unused_edge_test edges, start, finish, expected
    graph = Graph.new edges
    graph.dijkstra start
    graph.print_shortest_path finish
    graph.print_unused_edges finish
    actual = graph.unused_edges_as_array finish
    assert_equal expected, actual
  end
  
  #Given the parameters of the test and a set of edges, generates the graph and tests the print methods are correct
  def run_print_test edges, start, finish, expected
    graph = nil
    capture_console do #suppres the console chatter
      graph = Graph.new edges
      graph.dijkstra start
    end
    actual = capture_console do 
      graph.print_shortest_path finish
      graph.print_unused_edges finish
    end
    assert_equal expected, actual
  end
  
  #Captures anything printed to the console during a method execution and returns it as a string.
  #Takes a block, and for the duration of the execution of that block swaps the $stdout for a temp 
  #StringIO object. Can be used to suppress console chatter by wrapping an offending block.
  #
  #Returns whatever was captured by the temp StringIO as a String
  def capture_console(&block)
    stdout = $stdout
    $stdout = temp = StringIO.new
    begin
      yield if block_given?
    ensure
      $stdout = stdout
    end
    temp.string
  end
end
=end
