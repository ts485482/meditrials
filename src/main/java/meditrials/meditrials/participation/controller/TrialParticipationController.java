package meditrials.meditrials.participation.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import meditrials.meditrials.business.service.BusinessService;
import meditrials.meditrials.business.vo.BusinessVO;
import meditrials.meditrials.common.constant.SessionConstants;
import meditrials.meditrials.participation.service.TrialParticipationService;
import meditrials.meditrials.participation.vo.TrialParticipationVO;

@Controller
public class TrialParticipationController {

    private final TrialParticipationService trialParticipationService;
    private final BusinessService businessService;

    public TrialParticipationController(
            TrialParticipationService trialParticipationService,
            BusinessService businessService) {
        this.trialParticipationService = trialParticipationService;
        this.businessService = businessService;
    }

    @PostMapping("/trials/{trialNo}/participations/request")
    public String requestParticipation(
            @PathVariable Long trialNo,
            HttpServletRequest request,
            RedirectAttributes redirectAttributes) {

        Long memberNo = getLoginMemberNo(request);
        try {
            TrialParticipationVO participation = trialParticipationService.requestParticipation(memberNo, trialNo);
            redirectAttributes.addFlashAttribute("participationNotice", "참여 요청이 접수되었습니다. 사업자 검토 후 결과를 확인할 수 있습니다.");
            return "redirect:/mypage/participations?participationNo=" + participation.getParticipationNo();
        } catch (IllegalArgumentException | IllegalStateException exception) {
            redirectAttributes.addFlashAttribute("participationError", exception.getMessage());
            return "redirect:/trials/" + trialNo;
        }
    }

    @GetMapping("/mypage/participations")
    public String memberParticipations(
            @RequestParam(name = "participationNo", required = false) Long participationNo,
            HttpServletRequest request,
            Model model) {

        Long memberNo = getLoginMemberNo(request);
        List<TrialParticipationVO> participations = trialParticipationService.getMemberParticipations(memberNo);
        TrialParticipationVO selectedParticipation = resolveMemberSelectedParticipation(
                memberNo, participationNo, participations);

        model.addAttribute("participations", participations);
        model.addAttribute("selectedParticipation", selectedParticipation);
        return "mypage/participations";
    }

    @PostMapping("/mypage/participations/{participationNo}/withdraw")
    public String withdrawParticipation(
            @PathVariable Long participationNo,
            HttpServletRequest request,
            RedirectAttributes redirectAttributes) {

        Long memberNo = getLoginMemberNo(request);
        try {
            trialParticipationService.withdrawParticipation(memberNo, participationNo);
            redirectAttributes.addFlashAttribute("participationNotice", "참여 요청을 취소했습니다.");
        } catch (IllegalArgumentException | IllegalStateException exception) {
            redirectAttributes.addFlashAttribute("participationError", exception.getMessage());
        }
        return "redirect:/mypage/participations?participationNo=" + participationNo;
    }

    @GetMapping("/business/participations")
    public String businessParticipations(
            @RequestParam(name = "participationNo", required = false) Long participationNo,
            HttpServletRequest request,
            Model model) {

        BusinessVO business = getLoginBusiness(request);
        if (business == null) {
            model.addAttribute("businessError", "로그인 계정에 연결된 사업자 정보를 찾을 수 없습니다.");
            model.addAttribute("participations", List.of());
            return "business/participations";
        }

        List<TrialParticipationVO> participations = trialParticipationService.getBusinessParticipations(
                business.getBusinessNo());
        TrialParticipationVO selectedParticipation = resolveBusinessSelectedParticipation(
                business.getBusinessNo(), participationNo, participations);

        model.addAttribute("business", business);
        model.addAttribute("participations", participations);
        model.addAttribute("selectedParticipation", selectedParticipation);
        model.addAttribute("appliedCount", countByStatus(participations, "APPLIED"));
        model.addAttribute("approvedCount", countByStatus(participations, "APPROVED"));
        model.addAttribute("participatingCount", countByStatus(participations, "PARTICIPATING"));
        model.addAttribute("completedCount", countByStatus(participations, "COMPLETED"));
        model.addAttribute("rejectedCount", countByStatus(participations, "REJECTED"));
        return "business/participations";
    }

    @PostMapping("/business/participations/{participationNo}/approve")
    public String approveParticipation(
            @PathVariable Long participationNo,
            HttpServletRequest request,
            RedirectAttributes redirectAttributes) {

        BusinessVO business = getLoginBusiness(request);
        if (business == null) {
            return "redirect:/business/participations";
        }

        try {
            trialParticipationService.approveParticipation(business.getBusinessNo(), participationNo);
            redirectAttributes.addFlashAttribute("participationNotice", "참여 요청을 승인했습니다.");
        } catch (IllegalArgumentException | IllegalStateException exception) {
            redirectAttributes.addFlashAttribute("participationError", exception.getMessage());
        }
        return "redirect:/business/participations?participationNo=" + participationNo;
    }

    @PostMapping("/business/participations/{participationNo}/reject")
    public String rejectParticipation(
            @PathVariable Long participationNo,
            HttpServletRequest request,
            RedirectAttributes redirectAttributes) {

        BusinessVO business = getLoginBusiness(request);
        if (business == null) {
            return "redirect:/business/participations";
        }

        try {
            trialParticipationService.rejectParticipation(business.getBusinessNo(), participationNo);
            redirectAttributes.addFlashAttribute("participationNotice", "참여 요청을 거절했습니다.");
        } catch (IllegalArgumentException | IllegalStateException exception) {
            redirectAttributes.addFlashAttribute("participationError", exception.getMessage());
        }
        return "redirect:/business/participations?participationNo=" + participationNo;
    }


    @PostMapping("/business/participations/{participationNo}/start")
    public String startParticipation(
            @PathVariable Long participationNo,
            HttpServletRequest request,
            RedirectAttributes redirectAttributes) {

        BusinessVO business = getLoginBusiness(request);
        if (business == null) {
            return "redirect:/business/participations";
        }

        try {
            trialParticipationService.startParticipation(business.getBusinessNo(), participationNo);
            redirectAttributes.addFlashAttribute("participationNotice", "참여 상태를 '참여중'으로 변경했습니다.");
        } catch (IllegalArgumentException | IllegalStateException exception) {
            redirectAttributes.addFlashAttribute("participationError", exception.getMessage());
        }
        return "redirect:/business/participations?participationNo=" + participationNo;
    }

    @PostMapping("/business/participations/{participationNo}/complete")
    public String completeParticipation(
            @PathVariable Long participationNo,
            HttpServletRequest request,
            RedirectAttributes redirectAttributes) {

        BusinessVO business = getLoginBusiness(request);
        if (business == null) {
            return "redirect:/business/participations";
        }

        try {
            trialParticipationService.completeParticipation(business.getBusinessNo(), participationNo);
            redirectAttributes.addFlashAttribute("participationNotice", "임상시험 참여를 완료 상태로 변경했습니다.");
        } catch (IllegalArgumentException | IllegalStateException exception) {
            redirectAttributes.addFlashAttribute("participationError", exception.getMessage());
        }
        return "redirect:/business/participations?participationNo=" + participationNo;
    }

    private TrialParticipationVO resolveMemberSelectedParticipation(
            Long memberNo,
            Long participationNo,
            List<TrialParticipationVO> participations) {
        if (participationNo != null) {
            TrialParticipationVO selected = trialParticipationService.getMemberParticipation(memberNo, participationNo);
            if (selected != null) {
                return selected;
            }
        }
        return participations.isEmpty() ? null : participations.get(0);
    }

    private TrialParticipationVO resolveBusinessSelectedParticipation(
            Long businessNo,
            Long participationNo,
            List<TrialParticipationVO> participations) {
        if (participationNo != null) {
            TrialParticipationVO selected = trialParticipationService.getBusinessParticipation(businessNo, participationNo);
            if (selected != null) {
                return selected;
            }
        }
        return participations.isEmpty() ? null : participations.get(0);
    }

    private long countByStatus(List<TrialParticipationVO> participations, String status) {
        return participations.stream()
                .filter(participation -> status.equals(participation.getStatus()))
                .count();
    }

    private BusinessVO getLoginBusiness(HttpServletRequest request) {
        Long memberNo = getLoginMemberNo(request);
        if (memberNo == null) {
            return null;
        }
        return businessService.getBusinessByMemberNo(memberNo);
    }

    private Long getLoginMemberNo(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        Object memberNo = session.getAttribute(SessionConstants.LOGIN_MEMBER_NO);
        return memberNo instanceof Number number ? number.longValue() : null;
    }
}
