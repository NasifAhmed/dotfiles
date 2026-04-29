def read_float(prompt):
    while True:
        try:
            return float(input(prompt))
        except ValueError:
            print("Invalid input. Please enter a valid number.")


def main():
    print("Simple Python Calculator")
    num1 = read_float("Enter first number: ")
    operator = input("Enter operator (+, -, *, /): ").strip()
    num2 = read_float("Enter second number: ")

    if operator == "+":
        result = num1 + num2
    elif operator == "-":
        result = num1 - num2
    elif operator == "*":
        result = num1 * num2
    elif operator == "/":
        if num2 == 0:
            print("Error: Division by zero is not allowed.")
            return
        result = num1 / num2
    else:
        print("Error: Unsupported operator.")
        return

    print(f"Result: {num1:.4f} {operator} {num2:.4f} = {result:.4f}")


if __name__ == "__main__":
    main()
