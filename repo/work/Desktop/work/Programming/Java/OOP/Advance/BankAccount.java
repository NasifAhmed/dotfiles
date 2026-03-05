public class BankAccount {
    private double balance;

    public void deposit(double amount) {
        if(amount>0) {
            balance = balance + amount;
        }
    }
    
    public void withdraw(double amount) {
        if(amount>0) {
            balance = balance - amount;
        }
    }
    
    // Getter method
    public double getBalance() {
        return balance;
    }
}
