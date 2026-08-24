package meditrials.meditrials.business.stats.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import jakarta.servlet.http.HttpSession;
import meditrials.meditrials.business.stats.service.BusinessStatsService;
import meditrials.meditrials.business.subscription.service.BusinessSubscriptionService;
import meditrials.meditrials.common.constant.SessionConstants;

@Controller
@RequestMapping("/business")
public class BusinessStatsController {

    private final BusinessStatsService businessStatsService;
    private final BusinessSubscriptionService businessSubscriptionService;

    public BusinessStatsController(
            BusinessStatsService businessStatsService,
            BusinessSubscriptionService businessSubscriptionService) {
        this.businessStatsService = businessStatsService;
        this.businessSubscriptionService = businessSubscriptionService;
    }

    @GetMapping("/stats")
    public String stats(HttpSession session, Model model) {
        Long memberNo = getLoginMemberNo(session);
        if (!businessSubscriptionService.isPremiumActive(memberNo)) {
            return "redirect:/business/plans?premiumRequired=true";
        }

        model.addAttribute("stats", businessStatsService.getBusinessStats(memberNo));
        return "business/stats";
    }

    private Long getLoginMemberNo(HttpSession session) {
        Object value = session.getAttribute(SessionConstants.LOGIN_MEMBER_NO);
        return value instanceof Number number ? number.longValue() : null;
    }
}
