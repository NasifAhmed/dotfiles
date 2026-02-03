# Module 05: Object-Oriented Programming (OOP)

Welcome to one of the most important modules in Java programming! Object-Oriented Programming is a paradigm that helps you organize complex programs by modeling real-world objects.

## What You'll Learn

- Classes and Objects
- Encapsulation
- Inheritance
- Polymorphism
- Abstraction
- Constructors and methods
- Access modifiers

## Files in This Module

### 🏗️ Core OOP Examples
- **[Animal.java](./Animal.java)** - Basic class definition
- **[Animal2.java](./Animal2.java)** - Enhanced class with methods
- **[AnimalImplement.java](./AnimalImplement.java)** - Interface implementation
- **[Shape.java](./Shape.java)** - Abstract class example
- **[Circle.java](./Circle.java)** - Concrete implementation of Shape

### 🐾 Animal Examples
- **[Cat.java](./Cat.java)** - Specific animal class
- **[Cow.java](./Cow.java)** - Another animal implementation

### 🏦 Real-World Examples
- **[BankAccount.java](./BankAccount.java)** - Banking system example
- **[Car.java](./Car.java)** - Vehicle class implementation
- **[Player.java](./Player.java)** - Game character class

### 📋 Data Structure Examples
- **[MyArray.java](./MyArray.java)** - Custom array implementation
- **[MyList.java](./MyList.java)** - List interface implementation

### 🎯 Main Programs
- **[Main.java](./Main.java)** - Demonstrates OOP concepts

## Key OOP Concepts

### 1. Classes and Objects
```java
// Class is a blueprint
public class Car {
    String color;
    int speed;
    
    void accelerate() {
        speed += 10;
    }
}

// Object is an instance of a class
Car myCar = new Car();
myCar.color = "Red";
myCar.accelerate();
```

### 2. Encapsulation
Bundling data and methods that operate on that data within one unit.

### 3. Inheritance
Creating new classes from existing classes:
```java
public class Animal {
    void eat() { System.out.println("Eating"); }
}

public class Dog extends Animal {
    void bark() { System.out.println("Barking"); }
}
```

### 4. Polymorphism
One interface, multiple implementations.

## Practice Exercises

1. **Create a Person class** with name, age, and a introduce() method
2. **Extend the Animal class** to create your own animal type
3. **Design a BankAccount system** with deposit, withdraw, and balance check methods
4. **Create a game character** with health, experience, and special abilities

## How to Run Examples

1. **Compile all files**:
   ```bash
   javac *.java
   ```

2. **Run the main program**:
   ```bash
   java Main
   ```

3. **Or run individual classes** that have main methods

## Project Ideas

- 🏪 **Inventory Management System** - Track products with categories and prices
- 🎮 **Simple Game** - Create different types of game characters
- 📚 **Library System** - Model books, members, and borrowing
- 🏥 **Hospital Management** - Patients, doctors, appointments

## Next Steps

After mastering OOP concepts, explore:
- [Module 06: String Manipulation](../06-String-Manipulation)
- [Module 09: Recursion](../09-Recursion)
- [Module 10: Data Structures & Algorithms](../10-Data-Structures-Algorithms)

---

🎯 **Remember**: OOP is about thinking in terms of objects and their interactions. Practice modeling real-world scenarios!