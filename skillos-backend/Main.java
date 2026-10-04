
import java.sql.*;
public class Main {
    public static void main(String[] args) throws Exception {
        Connection c = DriverManager.getConnection("jdbc:mysql://localhost:3306/skillos_v1?useSSL=false&serverTimezone=UTC", "root", "");
        ResultSet rs = c.createStatement().executeQuery("SELECT column_type FROM information_schema.columns WHERE table_name=\"users\" AND column_name=\"id\"");
        if (rs.next()) {
            System.out.println("users.id type: " + rs.getString(1));
        }
        ResultSet rs2 = c.createStatement().executeQuery("SHOW CREATE TABLE user_routines");
        if (rs2.next()) {
            System.out.println("user_routines: " + rs2.getString(2));
        }
    }
}
