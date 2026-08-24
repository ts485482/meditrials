package meditrials.meditrials.admin.dashboard.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import meditrials.meditrials.admin.dashboard.service.AdminDashboardService;

@Controller
public class AdminDashboardController {

    private final AdminDashboardService adminDashboardService;

    public AdminDashboardController(AdminDashboardService adminDashboardService) {
        this.adminDashboardService = adminDashboardService;
    }

    @GetMapping("/admin")
    public String dashboard(Model model) {
        model.addAttribute("dashboard", adminDashboardService.getDashboardSummary());
        model.addAttribute("recentReviews", adminDashboardService.getRecentReviews());
        return "admin/dashboard";
    }
}
