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
import meditrials.meditrials.participation.service.TrialParticipationService;
import meditrials.meditrials.participation.vo.TrialParticipationVO;

@Controller
@RequestMapping("/business")
public class BusinessDashboardController {

    private final BusinessService businessService;
    private final BusinessTrialService businessTrialService;
    private final TrialParticipationService trialParticipationService;

    public BusinessDashboardController(
            BusinessService businessService,
            BusinessTrialService businessTrialService,
            TrialParticipationService trialParticipationService) {
        this.businessService = businessService;
        this.businessTrialService = businessTrialService;
        this.trialParticipationService = trialParticipationService;
    }

    @GetMapping
    public String dashboard(HttpSession session, Model model) {
        Long memberNo = getLoginMemberNo(session);
        BusinessVO business = businessService.getBusinessByMemberNo(memberNo);
        List<BusinessTrialVO> trials = businessTrialService.getBusinessTrials(memberNo);
        List<TrialParticipationVO> participations = business == null
                ? List.of()
                : trialParticipationService.getBusinessParticipations(business.getBusinessNo());

        model.addAttribute("business", business);
        model.addAttribute("trials", trials);
        model.addAttribute("draftCount", countByStatus(trials, "DRAFT"));
        model.addAttribute("pendingCount", countByStatus(trials, "PENDING"));
        model.addAttribute("approvedCount", countByStatus(trials, "APPROVED"));
        model.addAttribute("rejectedCount", countByStatus(trials, "REJECTED"));
        model.addAttribute("canManageTrials", businessTrialService.canManageTrials(memberNo));
        model.addAttribute("pendingParticipationCount", countParticipationByStatus(participations, "APPLIED"));
        model.addAttribute("activeParticipationCount", countActiveParticipations(participations));
        model.addAttribute("recentParticipations", participations.stream().limit(5).toList());
        return "business/dashboard";
    }

    private long countByStatus(List<BusinessTrialVO> trials, String status) {
        return trials.stream()
                .filter(trial -> status.equals(trial.getReviewStatus()))
                .count();
    }

    private long countParticipationByStatus(List<TrialParticipationVO> participations, String status) {
        return participations.stream()
                .filter(participation -> status.equals(participation.getStatus()))
                .count();
    }

    private long countActiveParticipations(List<TrialParticipationVO> participations) {
        return participations.stream()
                .filter(participation -> "APPROVED".equals(participation.getStatus())
                        || "PARTICIPATING".equals(participation.getStatus()))
                .count();
    }

    private Long getLoginMemberNo(HttpSession session) {
        Object value = session.getAttribute(SessionConstants.LOGIN_MEMBER_NO);
        return value instanceof Number number ? number.longValue() : null;
    }
}
