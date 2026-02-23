public class Rectangle {
    int length;
    int width;

    public Rectangle(int _length, int _width) {
        length = _length;
        width = _width;
    }

    public void enlarge(Rectangle shape) {
        length = length + shape.length;
        width = width + shape.width;
    }

    public void output() {
        System.out.println("("+length+", "+width+")");
    }
}
