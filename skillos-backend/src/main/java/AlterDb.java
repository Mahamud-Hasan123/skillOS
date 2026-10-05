import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

public class AlterDb {
    public static void main(String[] args) throws Exception {
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/skillos_v1?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true", "root", "");
        Statement stmt = conn.createStatement();
        stmt.executeUpdate("ALTER TABLE generation_jobs MODIFY COLUMN job_type VARCHAR(255) NOT NULL;");
        System.out.println("Successfully altered the column!");
    }
}
