package meditrials.meditrials.inquiry.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import meditrials.meditrials.common.constant.SessionConstants;
import meditrials.meditrials.inquiry.service.TrialInquiryService;
import meditrials.meditrials.inquiry.vo.TrialInquiryVO;
import meditrials.meditrials.trial.service.TrialService;
import meditrials.meditrials.trial.vo.TrialVO;

@Controller
public class TrialInquiryController {

    private final TrialInquiryService trialInquiryService;
    private final TrialService trialService;

    public TrialInquiryController(
            TrialInquiryService trialInquiryService,
            TrialService trialService) {
        this.trialInquiryService = trialInquiryService;
        this.trialService = trialService;
    }

    @GetMapping("/trials/{trialNo}/inquiries/new")
    public String inquiryForm(
            @PathVariable Long trialNo,
            HttpServletRequest request,
            Model model) {

        Long memberNo = getLoginMemberNo(request);
        if (memberNo == null) {
            return "redirect:/login?required=true";
        }

        TrialVO trial = trialService.getTrialDetail(trialNo);
        if (trial == null) {
            return "redirect:/trials?notFound=true";
        }

        model.addAttribute("trial", trial);
        return "trial/inquiry-form";
    }

    @PostMapping("/trials/{trialNo}/inquiries/new")
    public String createInquiry(
            @PathVariable Long trialNo,
            @RequestParam(name = "subject", defaultValue = "") String subject,
            @RequestParam(name = "question", defaultValue = "") String question,
            @RequestParam(name = "privacyAgreed", defaultValue = "false") boolean privacyAgreed,
            HttpServletRequest request,
            Model model) {

        Long memberNo = getLoginMemberNo(request);
        if (memberNo == null) {
            return "redirect:/login?required=true";
        }

        TrialVO trial = trialService.getTrialDetail(trialNo);
        if (trial == null) {
            return "redirect:/trials?notFound=true";
        }

        if (!privacyAgreed) {
            return renderFormError(
                    model,
                    trial,
                    subject,
                    question,
                    "개인정보 수집 및 문의 전달에 동의해주세요.");
        }

        try {
            Long inquiryNo = trialInquiryService.createInquiry(memberNo, trialNo, subject, question);
            return "redirect:/mypage/inquiries?created=true&inquiryNo=" + inquiryNo;
        } catch (IllegalArgumentException exception) {
            return renderFormError(model, trial, subject, question, exception.getMessage());
        }
    }

    @GetMapping("/mypage/inquiries")
    public String myInquiries(
            @RequestParam(name = "inquiryNo", required = false) Long inquiryNo,
            @RequestParam(name = "created", defaultValue = "false") boolean created,
            HttpServletRequest request,
            Model model) {

        Long memberNo = getLoginMemberNo(request);
        if (memberNo == null) {
            return "redirect:/login?required=true";
        }

        List<TrialInquiryVO> inquiries = trialInquiryService.getMemberInquiries(memberNo);
        TrialInquiryVO selectedInquiry = resolveSelectedInquiry(memberNo, inquiryNo, inquiries);

        model.addAttribute("inquiries", inquiries);
        model.addAttribute("selectedInquiry", selectedInquiry);
        if (created) {
            model.addAttribute("pageNotice", "참여 문의가 등록되었습니다.");
        }
        return "mypage/inquiries";
    }

    private TrialInquiryVO resolveSelectedInquiry(
            Long memberNo,
            Long inquiryNo,
            List<TrialInquiryVO> inquiries) {

        if (inquiryNo != null) {
            TrialInquiryVO selected = trialInquiryService.getMemberInquiry(memberNo, inquiryNo);
            if (selected != null) {
                return selected;
            }
        }
        return inquiries.isEmpty() ? null : inquiries.get(0);
    }

    private String renderFormError(
            Model model,
            TrialVO trial,
            String subject,
            String question,
            String errorMessage) {

        model.addAttribute("trial", trial);
        model.addAttribute("subject", subject == null ? "" : subject.trim());
        model.addAttribute("question", question == null ? "" : question.trim());
        model.addAttribute("formError", errorMessage);
        return "trial/inquiry-form";
    }

    private Long getLoginMemberNo(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }

        Object memberNo = session.getAttribute(SessionConstants.LOGIN_MEMBER_NO);
        if (memberNo instanceof Number number) {
            return number.longValue();
        }
        return null;
    }
}
