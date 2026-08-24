package meditrials.meditrials.business.trial.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import jakarta.servlet.http.HttpSession;
import meditrials.meditrials.business.service.BusinessService;
import meditrials.meditrials.business.trial.service.BusinessTrialService;
import meditrials.meditrials.business.trial.vo.BusinessTrialVO;
import meditrials.meditrials.business.vo.BusinessVO;
import meditrials.meditrials.common.constant.SessionConstants;

@Controller
@RequestMapping("/business/trials")
public class BusinessTrialController {

    private final BusinessTrialService businessTrialService;
    private final BusinessService businessService;

    public BusinessTrialController(
            BusinessTrialService businessTrialService,
            BusinessService businessService) {
        this.businessTrialService = businessTrialService;
        this.businessService = businessService;
    }

    @GetMapping
    public String list(
            @RequestParam(name = "result", required = false) String result,
            HttpSession session,
            Model model) {

        Long memberNo = loginMemberNo(session);
        BusinessVO business = businessService.getBusinessByMemberNo(memberNo);
        List<BusinessTrialVO> trials = businessTrialService.getBusinessTrials(memberNo);

        model.addAttribute("business", business);
        model.addAttribute("trials", trials);
        model.addAttribute("canManage", businessTrialService.canManageTrials(memberNo));
        model.addAttribute("pageNotice", resolveNotice(result));
        return "business/trials/list";
    }

    @GetMapping("/form")
    public String createForm(HttpSession session, Model model) {
        Long memberNo = loginMemberNo(session);
        if (!businessTrialService.canManageTrials(memberNo)) {
            return "redirect:/business/trials?result=notApproved";
        }

        BusinessVO business = businessService.getBusinessByMemberNo(memberNo);
        BusinessTrialVO trial = new BusinessTrialVO();
        if (business != null) {
            trial.setInstitutionName(business.getOrgName());
            trial.setContactPhone(business.getPhone());
        }

        prepareFormModel(model, trial, business, false, null);
        return "business/trials/form";
    }

    @GetMapping("/{trialNo}/edit")
    public String editForm(
            @PathVariable Long trialNo,
            HttpSession session,
            Model model) {

        Long memberNo = loginMemberNo(session);
        if (!businessTrialService.canManageTrials(memberNo)) {
            return "redirect:/business/trials?result=notApproved";
        }

        BusinessTrialVO trial = businessTrialService.getBusinessTrial(memberNo, trialNo);
        if (trial == null) {
            return "redirect:/business/trials?result=notFound";
        }

        prepareFormModel(
                model,
                trial,
                businessService.getBusinessByMemberNo(memberNo),
                true,
                null);
        return "business/trials/form";
    }

    @PostMapping("/save")
    public String save(
            BusinessTrialVO trial,
            @RequestParam(name = "action", defaultValue = "draft") String action,
            HttpSession session,
            Model model) {

        Long memberNo = loginMemberNo(session);
        BusinessVO business = businessService.getBusinessByMemberNo(memberNo);

        try {
            businessTrialService.saveBusinessTrial(memberNo, trial, action);
            return "redirect:/business/trials?result="
                    + ("review".equalsIgnoreCase(action) ? "pending" : "draft");
        } catch (IllegalArgumentException | IllegalStateException ex) {
            boolean edit = trial.getTrialNo() != null;
            prepareFormModel(model, trial, business, edit, ex.getMessage());
            return "business/trials/form";
        }
    }

    private void prepareFormModel(
            Model model,
            BusinessTrialVO trial,
            BusinessVO business,
            boolean edit,
            String formError) {
        model.addAttribute("trialForm", trial);
        model.addAttribute("business", business);
        model.addAttribute("diseaseOptions", businessTrialService.getDiseaseOptions());
        model.addAttribute("isEdit", edit);
        model.addAttribute("formError", formError);
    }

    private Long loginMemberNo(HttpSession session) {
        Object value = session.getAttribute(SessionConstants.LOGIN_MEMBER_NO);
        return value instanceof Number number ? number.longValue() : null;
    }

    private String resolveNotice(String result) {
        if (result == null) {
            return null;
        }
        return switch (result) {
            case "draft" -> "임상시험이 임시저장되었습니다.";
            case "pending" -> "검수 요청이 완료되었습니다. 관리자 승인 후 사용자 화면에 공개됩니다.";
            case "notApproved" -> "관리자 승인 완료 후 임상시험 등록·수정 기능을 사용할 수 있습니다.";
            case "notFound" -> "임상시험을 찾을 수 없거나 수정 권한이 없습니다.";
            default -> null;
        };
    }
}
