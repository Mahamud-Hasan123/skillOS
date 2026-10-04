import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class TestDB {
    public static void main(String[] args) {
        try {
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/skillos_v1?useSSL=false&allowPublicKeyRetrieval=true", "root", "");
            Statement stmt = conn.createStatement();
            
            System.out.println("--- TABLES IN skillos_v1 ---");
            ResultSet rs1 = stmt.executeQuery("SELECT table_name FROM information_schema.tables WHERE table_schema = 'skillos_v1'");
            while (rs1.next()) {
                System.out.println(rs1.getString(1));
            }
            
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
