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
    private static final Pattern ENGLISH_LETTER_PATTERN = Pattern.compile("[A-Za-z]");
    private static final String SPECIAL_CHARACTERS = "!@#$%^&*()_+-=[]{};:,.<>/?`~";

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
    public Map<String, Object> checkEmail(@RequestParam(defaultValue = "") String email) {
        if (isBlank(email) || !EMAIL_PATTERN.matcher(email.trim()).matches()) {
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
            @RequestParam(defaultValue = "") String email,
            @RequestParam(defaultValue = "") String password,
            @RequestParam(defaultValue = "") String passwordConfirm,
            @RequestParam(defaultValue = "") String memberName,
            @RequestParam(defaultValue = "") String phone,
            Model model) {

        String errorCode = validateSignup(email, password, passwordConfirm, memberName, phone);
        if (errorCode != null) {
            model.addAttribute("errorCode", errorCode);
            model.addAttribute("email", email.trim());
            model.addAttribute("memberName", memberName.trim());
            model.addAttribute("phone", phone.trim());
            return "member/signup";
        }

        if (memberService.isEmailDuplicated(email)) {
            model.addAttribute("errorCode", "EMAIL_DUPLICATED");
            model.addAttribute("email", email.trim());
            model.addAttribute("memberName", memberName.trim());
            model.addAttribute("phone", phone.trim());
            return "member/signup";
        }

        try {
            memberService.registerUser(email, password, memberName, phone);
        } catch (DataIntegrityViolationException exception) {
            model.addAttribute("errorCode", "EMAIL_DUPLICATED");
            model.addAttribute("email", email.trim());
            model.addAttribute("memberName", memberName.trim());
            model.addAttribute("phone", phone.trim());
            return "member/signup";
        } catch (IllegalStateException exception) {
            if ("EMAIL_DUPLICATED".equals(exception.getMessage())) {
                model.addAttribute("errorCode", "EMAIL_DUPLICATED");
                model.addAttribute("email", email.trim());
                model.addAttribute("memberName", memberName.trim());
                model.addAttribute("phone", phone.trim());
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

        if (isBlank(email)) {
            return "EMAIL_REQUIRED";
        }
        if (isBlank(password)) {
            return "PASSWORD_REQUIRED";
        }
        if (isBlank(passwordConfirm)) {
            return "PASSWORD_CONFIRM_REQUIRED";
        }
        if (isBlank(memberName)) {
            return "NAME_REQUIRED";
        }
        if (isBlank(phone)) {
            return "PHONE_REQUIRED";
        }
        if (!EMAIL_PATTERN.matcher(email.trim()).matches()) {
            return "EMAIL_INVALID";
        }
        if (!isValidPassword(password)) {
            return "PASSWORD_INVALID";
        }
        if (!password.equals(passwordConfirm)) {
            return "PASSWORD_MISMATCH";
        }
        return null;
    }

    private boolean isValidPassword(String password) {
        if (password.length() < 8 || !ENGLISH_LETTER_PATTERN.matcher(password).find()) {
            return false;
        }

        return password.chars()
                .mapToObj(character -> (char) character)
                .anyMatch(character -> SPECIAL_CHARACTERS.indexOf(character) >= 0);
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}
