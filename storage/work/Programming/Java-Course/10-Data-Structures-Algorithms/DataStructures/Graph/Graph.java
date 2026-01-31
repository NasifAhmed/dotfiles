import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.Queue;

public class Graph {
    private List<List<Integer>> adjacencyList;
    private int vertexCount;

    public Graph(int vertices) {
        vertexCount = vertices;
        adjacencyList = new ArrayList<>();
        for(int i=0; i<vertices; i++) {
            adjacencyList.add(new ArrayList<>());
        }
    }

    public void addEdge(int source, int destination) {
        if(source >= 0 && source < vertexCount && destination >= 0 && destination < vertexCount) {
            adjacencyList.get(source).add(destination);
            adjacencyList.get(destination).add(source);
        }
    }

    public void removeEdge(int source, int destination) {
        if(source >= 0 && source < vertexCount && destination >= 0 && destination < vertexCount) {
            adjacencyList.get(source).remove(Integer.valueOf(destination));
            adjacencyList.get(destination).remove(Integer.valueOf(source));
        }
    }

    public boolean hasEdge(int source, int destination) {
        if(source >= 0 && source < vertexCount && destination >= 0 && destination < vertexCount) {
            return adjacencyList.get(source).contains(destination);
        }
        return false;
    }

    public List<Integer> getNeighbors(int vertex) {
        if(vertex >= 0 && vertex < vertexCount) {
            return new ArrayList<>(adjacencyList.get(vertex));
        }
        return new ArrayList<>();
    }

    public void bfs(int startVertex) {
        if(startVertex < 0 || startVertex >= vertexCount) {
            System.out.println("Invalid start vertex");
            return;
        }

        boolean[] visited = new boolean[vertexCount];
        Queue<Integer> queue = new LinkedList<>();

        visited[startVertex] = true;
        queue.add(startVertex);

        System.out.print("BFS traversal: ");

        while(!queue.isEmpty()) {
            int vertex = queue.poll();
            System.out.print(vertex + " ");

            for(int neighbor : adjacencyList.get(vertex)) {
                if(!visited[neighbor]) {
                    visited[neighbor] = true;
                    queue.add(neighbor);
                }
            }
        }
        System.out.println();
    }

    public void dfs(int startVertex) {
        if(startVertex < 0 || startVertex >= vertexCount) {
            System.out.println("Invalid start vertex");
            return;
        }

        boolean[] visited = new boolean[vertexCount];
        System.out.print("DFS traversal: ");
        dfsRecursive(startVertex, visited);
        System.out.println();
    }

    private void dfsRecursive(int vertex, boolean[] visited) {
        visited[vertex] = true;
        System.out.print(vertex + " ");

        for(int neighbor : adjacencyList.get(vertex)) {
            if(!visited[neighbor]) {
                dfsRecursive(neighbor, visited);
            }
        }
    }

    public int getVertexCount() {
        return vertexCount;
    }

    public int getEdgeCount() {
        int count = 0;
        for(int i=0; i<vertexCount; i++) {
            count += adjacencyList.get(i).size();
        }
        return count / 2;
    }

    public void printGraph() {
        System.out.println("Adjacency List:");
        for(int i=0; i<vertexCount; i++) {
            System.out.print(i + " -> ");
            for(int neighbor : adjacencyList.get(i)) {
                System.out.print(neighbor + " ");
            }
            System.out.println();
        }
    }
}
