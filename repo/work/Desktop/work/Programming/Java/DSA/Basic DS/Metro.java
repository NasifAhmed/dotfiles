public class Metro {
    public static void main(String[] args) {
        Human nasif = new Teacher();

        System.out.println(nasif.laptop);

    }
}

class Human {
    String name = "";
    boolean laptop = false;
}

class Teacher extends Human {
    String name = "Sensei";
    boolean laptop = true;

}
