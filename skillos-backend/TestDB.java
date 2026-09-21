import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class TestDB {
    public static void main(String[] args) {
        try {
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/skillos_v1?useSSL=false&allowPublicKeyRetrieval=true", "root", "");
            Statement stmt = conn.createStatement();
            
            System.out.println("--- PROJECTS table ---");
            ResultSet rs1 = stmt.executeQuery("SELECT skill_name, COUNT(*) FROM projects GROUP BY skill_name");
            while (rs1.next()) {
                System.out.println(rs1.getString(1) + ": " + rs1.getInt(2));
            }
            
            System.out.println("\n--- ROADMAPS table ---");
            ResultSet rs2 = stmt.executeQuery("SELECT title, COUNT(DISTINCT user_id) FROM roadmaps GROUP BY title");
            while (rs2.next()) {
                System.out.println(rs2.getString(1) + ": " + rs2.getInt(2));
            }
            
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
