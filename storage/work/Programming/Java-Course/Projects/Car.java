public class Car {
  // Class er data/attribute/feature/variable
  String name = "911";
  String brand = "Porche";
  
  // Default constructor - hidden
  public Car() {};
  
  // Constructor
  public Car(String name, String brand) {
    this.name = name;
    this.brand = brand;
    drive();
  }
  
  // Class er method
  public void drive() {
    System.out.println(brand +" "+ name + " Car is running");
  }
}