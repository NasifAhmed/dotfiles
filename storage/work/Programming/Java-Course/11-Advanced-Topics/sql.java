import java.sql.*;

public class Main {
    public static void main(String[] args) {
        String url = "jdbc:mysql://132.145.12.13:3306/my_database";
        
        try (Connection conn = DriverManager.getConnection(url, "user", "pass")) {
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT name FROM users");
            
            while (rs.next()) {
                System.out.println(rs.getString("name"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}