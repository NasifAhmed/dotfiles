public class Main {
    public static void main(String[] args) {

        int[] a = { 12, 5, 190, 80, 70 };

        int smallest = a[0];
        for(int i=0 ; i<a.length ; i++) {
            if(a[i] < smallest){
                smallest = a[i];
            }
        }

        System.out.println(smallest);

    }
}
