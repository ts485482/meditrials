package meditrials.meditrials.common.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import meditrials.meditrials.trial.service.TrialService;

@Controller
public class PageController {

    private final TrialService trialService;

    public PageController(TrialService trialService) {
        this.trialService = trialService;
    }

    @GetMapping("/")
    public String root() {
        return "redirect:/main";
    }

    @GetMapping("/main")
    public String main(Model model) {
        model.addAttribute("premiumTrials", trialService.getActivePremiumTrials(3));
        return "main";
    }

    @GetMapping("/login")
    public String login(
            @RequestParam(name = "required", defaultValue = "false") boolean required,
            @RequestParam(name = "businessSignup", defaultValue = "") String businessSignup,
            Model model) {

        if (required) {
            model.addAttribute(
                    "loginNotice",
                    "로그인이 필요한 메뉴입니다. 로그인 후 이용해주세요.");
        } else if ("success".equals(businessSignup)) {
            model.addAttribute(
                    "loginNotice",
                    "사업자 가입 신청이 완료되었습니다. 로그인은 가능하며, 임상시험 등록은 관리자 승인 후 사용할 수 있습니다.");
        }

        return "auth/login";
    }


}
