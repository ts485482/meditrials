package meditrials.meditrials.common.service;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Map;

import javax.sql.DataSource;

import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class DatabaseConnectionService {

    private final JdbcTemplate jdbcTemplate;
    private final DataSource dataSource;

    public DatabaseConnectionService(JdbcTemplate jdbcTemplate, DataSource dataSource) {
        this.jdbcTemplate = jdbcTemplate;
        this.dataSource = dataSource;
    }

    /**
     * Oracle 연결 여부를 실제 쿼리(SELECT 1 FROM DUAL)로 확인한다.
     * 비밀번호나 접속 URL 같은 민감한 정보는 응답에 포함하지 않는다.
     */
    public Map<String, Object> checkConnection() {
        Map<String, Object> result = new LinkedHashMap<>();

        try {
            Integer value = jdbcTemplate.queryForObject("SELECT 1 FROM DUAL", Integer.class);

            result.put("connected", Integer.valueOf(1).equals(value));
            result.put("message", "Oracle DB 연결에 성공했습니다.");
            addDatabaseInfo(result);
        } catch (DataAccessException ex) {
            result.put("connected", false);
            result.put("message", "Oracle DB 연결에 실패했습니다.");
            result.put("error", getRootMessage(ex));
        }

        return result;
    }

    private void addDatabaseInfo(Map<String, Object> result) {
        try (Connection connection = dataSource.getConnection()) {
            DatabaseMetaData metaData = connection.getMetaData();
            result.put("database", metaData.getDatabaseProductName());
            result.put("databaseVersion", metaData.getDatabaseProductVersion());
        } catch (SQLException ex) {
            result.put("databaseInfo", "연결은 성공했지만 DB 버전 정보를 읽지 못했습니다.");
        }
    }

    private String getRootMessage(Throwable throwable) {
        Throwable current = throwable;
        while (current.getCause() != null) {
            current = current.getCause();
        }

        String message = current.getMessage();
        return message == null || message.isBlank()
                ? current.getClass().getSimpleName()
                : message;
    }
}
