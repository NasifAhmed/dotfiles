public class Cow extends Animal {
    String name = "Cow";
    String sound = "Hamba";
    String milk = "Milk" ;
    
    void speak() {
        System.out.println(name +" says " + sound);
    }
    
    void eatGrass(){};
}