package meditrials.meditrials.admin.revenue.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import meditrials.meditrials.admin.revenue.service.AdminRevenueService;

@Controller
public class AdminRevenueController {

    private final AdminRevenueService adminRevenueService;

    public AdminRevenueController(AdminRevenueService adminRevenueService) {
        this.adminRevenueService = adminRevenueService;
    }

    @GetMapping("/admin/revenue")
    public String revenue(Model model) {
        model.addAttribute("summary", adminRevenueService.getRevenueSummary());
        model.addAttribute("monthlyRevenue", adminRevenueService.getMonthlyRevenueList());
        return "admin/revenue";
    }
}
