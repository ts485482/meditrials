package meditrials.meditrials.mypage.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import meditrials.meditrials.common.constant.SessionConstants;
import meditrials.meditrials.member.vo.MemberVO;
import meditrials.meditrials.mypage.service.MypageService;

@Controller
@RequestMapping("/mypage")
public class MypageController {

    private final MypageService mypageService;

    public MypageController(MypageService mypageService) {
        this.mypageService = mypageService;
    }

    @GetMapping
    public String main(HttpServletRequest request, Model model) {
        Long memberNo = getLoginMemberNo(request);
        model.addAttribute("member", mypageService.getMemberProfile(memberNo));
        model.addAttribute("summary", mypageService.getSummary(memberNo));
        model.addAttribute("recentFavoriteDiseases", mypageService.getRecentFavoriteDiseases(memberNo));
        model.addAttribute("recentFavoriteTrials", mypageService.getRecentFavoriteTrials(memberNo));
        model.addAttribute("recentInquiries", mypageService.getRecentInquiries(memberNo));
        return "mypage/main";
    }

    @GetMapping("/profile")
    public String profile(HttpServletRequest request, Model model) {
        model.addAttribute("member", mypageService.getMemberProfile(getLoginMemberNo(request)));
        return "mypage/profile";
    }

    @PostMapping("/profile")
    public String updateProfile(
            @RequestParam(defaultValue = "") String memberName,
            @RequestParam(defaultValue = "") String phone,
            HttpServletRequest request,
            Model model,
            RedirectAttributes redirectAttributes) {

        Long memberNo = getLoginMemberNo(request);
        try {
            MemberVO member = mypageService.updateMemberProfile(memberNo, memberName, phone);
            syncMemberNameSession(request, member);
            redirectAttributes.addFlashAttribute("profileSuccess", "회원정보가 수정되었습니다.");
            return "redirect:/mypage/profile";
        } catch (IllegalArgumentException | IllegalStateException exception) {
            model.addAttribute("member", mypageService.getMemberProfile(memberNo));
            model.addAttribute("formMemberName", memberName);
            model.addAttribute("formPhone", phone);
            model.addAttribute("profileError", exception.getMessage());
            return "mypage/profile";
        }
    }

    @GetMapping("/password")
    public String passwordForm() {
        return "mypage/password";
    }

    @PostMapping("/password")
    public String changePassword(
            @RequestParam(defaultValue = "") String currentPassword,
            @RequestParam(defaultValue = "") String newPassword,
            @RequestParam(defaultValue = "") String passwordConfirm,
            HttpServletRequest request,
            Model model,
            RedirectAttributes redirectAttributes) {

        try {
            mypageService.changePassword(
                    getLoginMemberNo(request),
                    currentPassword,
                    newPassword,
                    passwordConfirm);
            redirectAttributes.addFlashAttribute("passwordSuccess", "비밀번호가 변경되었습니다.");
            return "redirect:/mypage/password";
        } catch (IllegalArgumentException | IllegalStateException exception) {
            model.addAttribute("passwordError", exception.getMessage());
            return "mypage/password";
        }
    }

    private Long getLoginMemberNo(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        Object memberNo = session.getAttribute(SessionConstants.LOGIN_MEMBER_NO);
        return memberNo instanceof Number number ? number.longValue() : null;
    }

    private void syncMemberNameSession(HttpServletRequest request, MemberVO member) {
        if (member == null) {
            return;
        }
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.setAttribute(SessionConstants.LOGIN_MEMBER_NAME, member.getMemberName());
        }
    }
}
