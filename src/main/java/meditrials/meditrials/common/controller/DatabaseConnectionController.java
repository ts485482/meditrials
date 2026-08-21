package meditrials.meditrials.common.controller;

import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import meditrials.meditrials.common.service.DatabaseConnectionService;

@RestController
@RequestMapping("/db")
public class DatabaseConnectionController {

    private final DatabaseConnectionService databaseConnectionService;

    public DatabaseConnectionController(DatabaseConnectionService databaseConnectionService) {
        this.databaseConnectionService = databaseConnectionService;
    }

    @GetMapping("/check")
    public ResponseEntity<Map<String, Object>> checkConnection() {
        Map<String, Object> result = databaseConnectionService.checkConnection();
        boolean connected = Boolean.TRUE.equals(result.get("connected"));

        return ResponseEntity
                .status(connected ? HttpStatus.OK : HttpStatus.SERVICE_UNAVAILABLE)
                .body(result);
    }
}
