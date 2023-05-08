import 'dart:io';
import 'package:collection/collection.dart';

class Node {
  int value;
  double distance;

  Node(this.value, this.distance);
}
void func(String n){
  n = "asdas";
}
void Print(List<int> path, int currNode){
  if (path[currNode] == -2){
    print(currNode);
  }else{
    Print(path,path[currNode]);
    print(currNode);
  }
}
void findMinPath(Map<int,List<Node>> graph, int s, int goal) {

  int compareByAgeDesc(Node a, Node b) => a.distance.compareTo(b.distance);
  HeapPriorityQueue<Node> q = HeapPriorityQueue(compareByAgeDesc);
  List<double> dist = List.filled(graph.length+1, 1.0/0.0);
  List<int> path = List.filled(graph.length+1, -1);

  dist[s] = 0;
  path[s] = -2;
  q.add(Node(s,0));
  while(! q.isEmpty) {

    Node u = q.first;
    q.removeFirst();
    if(u.value == goal){
      q.clear();
      break;
    }

    graph[u.value]!.forEach((node) {

      int v = node.value;
      double weight = node.distance;

      if (dist[u.value] + weight < dist[v] ){
        path[v] = u.value;
        dist[v] = dist[u.value] + weight;
        q.add(Node(v,dist[v]));
      }

    });
  }
  Print(path,goal);

}
void main() {
  String n = "Huz";
  func(n);
  print(n);
  // Map<int, List<Node>> graph = {
  //   0: [Node(1, 7), Node(2, 5)],
  //   1: [Node(2, 2), Node(3, 1)],
  //   2: [Node(1, 3), Node(4, 1), Node(3, 9)],
  //   3: [Node(4, 4)],
  //   4: [Node(0, 7), Node(3, 1)]
  // };
  // findMinPath(graph,0,3);

}

