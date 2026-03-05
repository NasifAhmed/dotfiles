import java.util.Arrays;
import java.util.stream.IntStream;

public class ParallelDemo {

    // We use a larger number to make the performance difference noticeable
    // 100 million integers
    private static final int TARGET_SIZE = 100_000_000;

    public static void main(String[] args) {
        System.out.println("Generating " + TARGET_SIZE + " numbers...\n");

        // --- SINGLE THREADED ---
        long startSingle = System.currentTimeMillis();
        
        int[] singleResult = generateSingleThreaded();
        
        long endSingle = System.currentTimeMillis();
        System.out.println("Single-Threaded Time: " + (endSingle - startSingle) + " ms");


        // --- MULTI THREADED (PARALLEL) ---
        // Force JVM to initialize the common ForkJoinPool to avoid initialization lag in the benchmark
        IntStream.range(0, 1).parallel().toArray(); 

        long startParallel = System.currentTimeMillis();
        
        int[] parallelResult = generateMultiThreaded();
        
        long endParallel = System.currentTimeMillis();
        System.out.println("Multi-Threaded Time:  " + (endParallel - startParallel) + " ms");
        
        // Verification (Optional)
        System.out.println("\nArrays are equal size? " + (singleResult.length == parallelResult.length));
    }

    // Method 1: Single Thread (Standard Loop)
    public static int[] generateSingleThreaded() {
        int[] arr = new int[TARGET_SIZE];
        for (int i = 0; i < TARGET_SIZE; i++) {
            // We perform a small calculation to simulate 'work'
            // Otherwise, memory allocation dominates the time, not CPU
            arr[i] = i * 2; 
        }
        return arr;
    }

    // Method 2: Multiple Threads (Java Parallel Streams)
    public static int[] generateMultiThreaded() {
        return IntStream.range(0, TARGET_SIZE)
                .parallel() // This enables multi-threading
                .map(i -> i * 2) // Same calculation
                .toArray();
    }
}
