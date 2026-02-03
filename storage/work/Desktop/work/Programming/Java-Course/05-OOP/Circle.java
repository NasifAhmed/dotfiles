public class Circle extends Shape {
    double radius;

    public double area() {
        return 3.1416*radius*radius;
    }
    
    public int add(int a, int b, int c) {
        return a+b+c;
    }
    public int add(int a, int b, int c, int d) {
        return a+b+c+d;
    }
}