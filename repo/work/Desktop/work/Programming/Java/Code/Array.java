import java.util.HashSet;

public class Array {
    public static void main(String[] args) {

        int[] a = { 10, 5, 2, 33, 5, 60 };

        HashSet<Integer> seen = new HashSet<>();
        boolean duplicateAse = false;
        for(int num : a) {
            if(seen.contains(num)) {
                duplicateAse = true;
                break;
            }
            seen.add(num);
        }

        if(duplicateAse == true) {
            System.out.println("Duplicate Ase");
        } else {
            System.out.println("Duplicate Nai");
        }
    }
}
// 1. Sum of Array
// 2. Average of Array
// 3. Duplicate Detector
