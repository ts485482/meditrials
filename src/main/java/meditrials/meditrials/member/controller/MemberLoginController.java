package meditrials.meditrials.member.controller;

import java.util.regex.Pattern;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import meditrials.meditrials.common.constant.SessionConstants;
import meditrials.meditrials.member.service.MemberService;
import meditrials.meditrials.member.vo.MemberVO;

@Controller
public class MemberLoginController {

    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");

    private static final String STATUS_ACTIVE = "ACTIVE";
    private static final String ROLE_USER = "USER";
    private static final String ROLE_BUSINESS = "BUSINESS";
    private static final String ROLE_ADMIN = "ADMIN";
    private static final int SESSION_TIMEOUT_SECONDS = 30 * 60;

    private final MemberService memberService;

    public MemberLoginController(MemberService memberService) {
        this.memberService = memberService;
    }

    @PostMapping("/login")
    public String login(
            @RequestParam(defaultValue = "") String email,
            @RequestParam(defaultValue = "") String password,
            HttpServletRequest request,
            Model model) {

        if (email.isBlank() || password.isBlank()) {
            model.addAttribute("loginErrorCode", "LOGIN_REQUIRED");
            return "auth/login";
        }

        if (!EMAIL_PATTERN.matcher(email.trim()).matches()) {
            model.addAttribute("loginErrorCode", "EMAIL_INVALID");
            return "auth/login";
        }

        MemberVO member = memberService.authenticate(email, password);
        if (member == null) {
            model.addAttribute("loginErrorCode", "AUTH_FAILED");
            return "auth/login";
        }

        if (!STATUS_ACTIVE.equals(member.getStatus())) {
            model.addAttribute("loginErrorCode", "ACCOUNT_INACTIVE");
            return "auth/login";
        }

        HttpSession session = request.getSession(true);
        request.changeSessionId();
        session.setMaxInactiveInterval(SESSION_TIMEOUT_SECONDS);
        session.setAttribute(SessionConstants.LOGIN_MEMBER_NO, member.getMemberNo());
        session.setAttribute(SessionConstants.LOGIN_MEMBER_EMAIL, member.getEmail());
        session.setAttribute(SessionConstants.LOGIN_MEMBER_NAME, member.getMemberName());
        session.setAttribute(SessionConstants.LOGIN_MEMBER_ROLE, member.getRoleCode());

        return redirectByRole(member.getRoleCode());
    }

    @PostMapping("/logout")
    public String logout(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        return "redirect:/main";
    }

    private String redirectByRole(String roleCode) {
        if (ROLE_ADMIN.equals(roleCode)) {
            return "redirect:/admin";
        }
        if (ROLE_BUSINESS.equals(roleCode)) {
            return "redirect:/business";
        }
        if (ROLE_USER.equals(roleCode)) {
            return "redirect:/main";
        }
        return "redirect:/main";
    }
}
