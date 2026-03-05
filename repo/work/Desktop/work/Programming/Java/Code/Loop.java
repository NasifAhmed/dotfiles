public class Loop {
    public static void main(String[] args) {
        // Baar baar koro
        int i = 1;
        int sum = 0;
        while(i<=1000) {
            sum = sum + i;
            i = i + 1;
        }
        System.out.println("Jogfol = " +sum);
    }
}
