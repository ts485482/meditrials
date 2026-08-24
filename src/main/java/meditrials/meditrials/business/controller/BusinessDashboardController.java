package meditrials.meditrials.business.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import jakarta.servlet.http.HttpSession;
import meditrials.meditrials.business.service.BusinessService;
import meditrials.meditrials.business.trial.service.BusinessTrialService;
import meditrials.meditrials.business.trial.vo.BusinessTrialVO;
import meditrials.meditrials.business.vo.BusinessVO;
import meditrials.meditrials.common.constant.SessionConstants;

@Controller
@RequestMapping("/business")
public class BusinessDashboardController {

    private final BusinessService businessService;
    private final BusinessTrialService businessTrialService;

    public BusinessDashboardController(
            BusinessService businessService,
            BusinessTrialService businessTrialService) {
        this.businessService = businessService;
        this.businessTrialService = businessTrialService;
    }

    @GetMapping
    public String dashboard(HttpSession session, Model model) {
        Long memberNo = getLoginMemberNo(session);
        BusinessVO business = businessService.getBusinessByMemberNo(memberNo);
        List<BusinessTrialVO> trials = businessTrialService.getBusinessTrials(memberNo);

        model.addAttribute("business", business);
        model.addAttribute("trials", trials);
        model.addAttribute("draftCount", countByStatus(trials, "DRAFT"));
        model.addAttribute("pendingCount", countByStatus(trials, "PENDING"));
        model.addAttribute("approvedCount", countByStatus(trials, "APPROVED"));
        model.addAttribute("rejectedCount", countByStatus(trials, "REJECTED"));
        model.addAttribute("canManageTrials", businessTrialService.canManageTrials(memberNo));
        return "business/dashboard";
    }

    private long countByStatus(List<BusinessTrialVO> trials, String status) {
        return trials.stream()
                .filter(trial -> status.equals(trial.getReviewStatus()))
                .count();
    }

    private Long getLoginMemberNo(HttpSession session) {
        Object value = session.getAttribute(SessionConstants.LOGIN_MEMBER_NO);
        return value instanceof Number number ? number.longValue() : null;
    }
}
