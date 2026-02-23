public class Cuboid extends Rectangle {
    int height;

    public Cuboid(int _length, int _width, int _height) {
        super.length = _length;
        super.width = _width;
        height = _height;
    }

    public void enlarge(Cuboid shape) {
        super.length = super.length + shape.length;
        super.width = super.width + shape.width;
        height = height + shape.height;

    }

    public void output() {
        System.out.println("("+length+", "+width+", "+height+")");
    }
    
}
