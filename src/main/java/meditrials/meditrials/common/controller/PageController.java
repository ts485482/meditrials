package meditrials.meditrials.common.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@Controller
public class PageController {

    @GetMapping("/")
    public String root() {
        return "redirect:/main";
    }

    @GetMapping("/main")
    public String main() {
        return "main";
    }

    @GetMapping("/login")
    public String login() {
        return "auth/login";
    }

    @GetMapping("/member/signup")
    public String memberSignup() {
        return "member/signup";
    }

    @GetMapping("/business/signup")
    public String businessSignup() {
        return "business/signup";
    }

    @GetMapping("/diseases")
    public String diseaseList() {
        return "disease/list";
    }

    @GetMapping("/diseases/{id}")
    public String diseaseDetail(@PathVariable String id) {
        return "disease/detail";
    }

    @GetMapping("/trials")
    public String trialList() {
        return "trial/list";
    }

    @GetMapping("/trials/{id}")
    public String trialDetail(@PathVariable String id) {
        return "trial/detail";
    }

    @GetMapping("/trials/{id}/inquiries/new")
    public String inquiryForm(@PathVariable String id) {
        return "trial/inquiry-form";
    }

    @GetMapping("/mypage")
    public String mypage() {
        return "mypage/main";
    }

    @GetMapping("/mypage/favorites")
    public String favorites() {
        return "mypage/favorites";
    }

    @GetMapping("/mypage/inquiries")
    public String myInquiries() {
        return "mypage/inquiries";
    }

    @GetMapping("/business")
    public String businessDashboard() {
        return "business/dashboard";
    }

    @GetMapping("/business/trials")
    public String businessTrials() {
        return "business/trials/list";
    }

    @GetMapping("/business/trials/form")
    public String businessTrialForm() {
        return "business/trials/form";
    }

    @GetMapping("/business/trials/{id}/edit")
    public String businessTrialEdit(@PathVariable String id) {
        return "business/trials/form";
    }

    @GetMapping("/business/inquiries")
    public String businessInquiries() {
        return "business/inquiries";
    }

    @GetMapping("/business/plans")
    public String businessPlans() {
        return "business/plans";
    }

    @GetMapping("/business/stats")
    public String businessStats() {
        return "business/stats";
    }

    @GetMapping("/admin")
    public String adminDashboard() {
        return "admin/dashboard";
    }

    @GetMapping("/admin/businesses")
    public String adminBusinesses() {
        return "admin/businesses";
    }

    @GetMapping("/admin/trials")
    public String adminTrials() {
        return "admin/trials";
    }

    @GetMapping("/admin/members")
    public String adminMembers() {
        return "admin/members";
    }

    @GetMapping("/admin/plans")
    public String adminPlans() {
        return "admin/plans";
    }

    @GetMapping("/admin/payments")
    public String adminPayments() {
        return "admin/payments";
    }

    @GetMapping("/admin/promotions")
    public String adminPromotions() {
        return "admin/promotions";
    }

    @GetMapping("/admin/revenue")
    public String adminRevenue() {
        return "admin/revenue";
    }
}
