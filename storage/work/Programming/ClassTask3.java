class ClassTask3 {
    static int strange(int n) {
        if (n <= 1) return n;
        if (n % 2 == 0) return strange(n / 2);
        else return strange(n - 1) + 1;
    }
    public static void main(String[] args) {
        System.out.println(strange(7));
    }
}
