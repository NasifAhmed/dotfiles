public class Recap {
    public static void main(String[] args) {
        // condition
        int birthYear = 2022;
        //
        // if age less than 10 ticket free
        // if age greater than 10 but less than 90 then not free
        // if age greater than 90 ticket free
        if(age<10) {
            System.out.println("Free");
        } else if(age>10 && age<90) {
            System.out.println("Not free");
        } else if(age>90) {
            System.out.println("Not free");
        }

        if(age<10 || age >90) {
            System.out.println("Free");
        } else {
            System.out.println("Not free");
        }
    }
}
