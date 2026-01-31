class Animal {
    int eyes = 2;
    int legs = 4;
    boolean alive = true;
    public void speak(){};
}

class Dog extends Animal {
    public void speak() {
        System.out.println("Bark");
    }
}

class Cat extends Animal {
    public void speak() {
        System.out.println("Meow");
    }
}

class Cow extends Animal {
    public void speak() {
        System.out.println("Moooo");
    }
}

public class test {
    public static void main(String[] args) {
        Animal testAnimal = new Dog();
        
        testAnimal.speak();

        testAnimal = new Cat();

        testAnimal.speak();

        testAnimal = new Cow();
        testAnimal.speak();
    }
}