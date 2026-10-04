import java.sql.*;
public class DropDB {
    public static void main(String[] args) throws Exception {
        Connection c = DriverManager.getConnection("jdbc:mysql://localhost:3306/?useSSL=false&serverTimezone=UTC", "root", "");
        Statement s = c.createStatement();
        s.execute("DROP DATABASE IF EXISTS skillos_v1");
        s.execute("CREATE DATABASE skillos_v1");
        System.out.println("Database dropped and recreated!");
    }
}
