package meditrials.meditrials.common.controller;

import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import meditrials.meditrials.common.service.MyBatisTableCheckService;

@RestController
@RequestMapping("/db")
public class MyBatisTableCheckController {

    private final MyBatisTableCheckService myBatisTableCheckService;

    public MyBatisTableCheckController(MyBatisTableCheckService myBatisTableCheckService) {
        this.myBatisTableCheckService = myBatisTableCheckService;
    }

    @GetMapping("/mybatis-check")
    public ResponseEntity<Map<String, Object>> checkMyBatis() {
        Map<String, Object> result = myBatisTableCheckService.check();
        boolean success = Boolean.TRUE.equals(result.get("mybatis"));

        return ResponseEntity
                .status(success ? HttpStatus.OK : HttpStatus.SERVICE_UNAVAILABLE)
                .body(result);
    }
}
