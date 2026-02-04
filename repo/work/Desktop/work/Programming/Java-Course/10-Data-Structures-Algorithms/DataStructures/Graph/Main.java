public class Main {
    public static void main(String[] args) {
        Graph graph = new Graph(6);
        System.out.println("Graph operations:");
        System.out.println("Number of vertices: " + graph.getVertexCount());
        System.out.println("Number of edges: " + graph.getEdgeCount());

        graph.addEdge(0, 1);
        graph.addEdge(0, 2);
        graph.addEdge(1, 3);
        graph.addEdge(1, 4);
        graph.addEdge(2, 5);

        System.out.println("After adding edges: (0-1), (0-2), (1-3), (1-4), (2-5)");
        System.out.println("Number of edges: " + graph.getEdgeCount());

        graph.printGraph();

        System.out.println("Has edge 0-1: " + graph.hasEdge(0, 1));
        System.out.println("Has edge 3-5: " + graph.hasEdge(3, 5));

        System.out.println("Neighbors of vertex 1: " + graph.getNeighbors(1));
        System.out.println("Neighbors of vertex 3: " + graph.getNeighbors(3));

        graph.bfs(0);
        graph.dfs(0);

        graph.removeEdge(1, 3);
        System.out.println("After removing edge (1-3):");
        System.out.println("Has edge 1-3: " + graph.hasEdge(1, 3));
        graph.printGraph();

        graph.bfs(0);
        graph.dfs(0);
    }
}
