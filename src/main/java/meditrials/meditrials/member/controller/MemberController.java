package meditrials.meditrials.member.controller;

import java.util.Map;
import java.util.regex.Pattern;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import meditrials.meditrials.member.service.MemberService;

@Controller
@RequestMapping("/member")
public class MemberController {

    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");

    private final MemberService memberService;

    public MemberController(MemberService memberService) {
        this.memberService = memberService;
    }

    @GetMapping("/signup")
    public String signupForm() {
        return "member/signup";
    }

    @GetMapping("/check-email")
    @ResponseBody
    public Map<String, Object> checkEmail(@RequestParam String email) {
        if (email.isBlank() || !EMAIL_PATTERN.matcher(email.trim()).matches()) {
            return Map.of(
                    "available", false,
                    "message", "올바른 이메일 형식을 입력해주세요.");
        }

        boolean duplicated = memberService.isEmailDuplicated(email);
        return Map.of(
                "available", !duplicated,
                "message", duplicated ? "이미 사용 중인 이메일입니다." : "사용 가능한 이메일입니다.");
    }

    @PostMapping("/signup")
    public String signup(
            @RequestParam String email,
            @RequestParam String password,
            @RequestParam String passwordConfirm,
            @RequestParam String memberName,
            @RequestParam String phone,
            Model model) {

        String errorCode = validateSignup(email, password, passwordConfirm, memberName, phone);
        if (errorCode != null) {
            model.addAttribute("errorCode", errorCode);
            return "member/signup";
        }

        if (memberService.isEmailDuplicated(email)) {
            model.addAttribute("errorCode", "EMAIL_DUPLICATED");
            return "member/signup";
        }

        try {
            memberService.registerUser(email, password, memberName, phone);
        } catch (DataIntegrityViolationException exception) {
            model.addAttribute("errorCode", "EMAIL_DUPLICATED");
            return "member/signup";
        } catch (IllegalStateException exception) {
            if ("EMAIL_DUPLICATED".equals(exception.getMessage())) {
                model.addAttribute("errorCode", "EMAIL_DUPLICATED");
                return "member/signup";
            }
            throw exception;
        }

        return "redirect:/login";
    }

    private String validateSignup(
            String email,
            String password,
            String passwordConfirm,
            String memberName,
            String phone) {

        if (email.isBlank() || password.isBlank() || passwordConfirm.isBlank()
                || memberName.isBlank() || phone.isBlank()) {
            return "REQUIRED";
        }
        if (!EMAIL_PATTERN.matcher(email.trim()).matches()) {
            return "EMAIL_INVALID";
        }
        if (!password.equals(passwordConfirm)) {
            return "PASSWORD_MISMATCH";
        }
        return null;
    }
}
