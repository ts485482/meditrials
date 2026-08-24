package meditrials.meditrials.admin.member.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import meditrials.meditrials.admin.member.service.AdminMemberService;

@Controller
@RequestMapping("/admin/members")
public class AdminMemberController {

    private final AdminMemberService adminMemberService;

    public AdminMemberController(AdminMemberService adminMemberService) {
        this.adminMemberService = adminMemberService;
    }

    @GetMapping
    public String members(
            @RequestParam(defaultValue = "") String keyword,
            @RequestParam(required = false) Long memberNo,
            Model model) {

        model.addAttribute("members", adminMemberService.getMembers(keyword));
        model.addAttribute("keyword", keyword == null ? "" : keyword.trim());
        model.addAttribute("activeCount", adminMemberService.getActiveCount());
        model.addAttribute("suspendedCount", adminMemberService.getSuspendedCount());
        model.addAttribute("withdrawnCount", adminMemberService.getWithdrawnCount());

        if (memberNo != null) {
            model.addAttribute("selectedMember", adminMemberService.getMember(memberNo));
        }

        return "admin/members";
    }

    @PostMapping("/{memberNo}/suspend")
    public String suspend(
            @PathVariable Long memberNo,
            RedirectAttributes redirectAttributes) {
        try {
            adminMemberService.suspendMember(memberNo);
            redirectAttributes.addFlashAttribute("pageNotice", "회원 이용을 정지했습니다.");
        } catch (IllegalArgumentException | IllegalStateException exception) {
            redirectAttributes.addFlashAttribute("pageError", exception.getMessage());
        }
        redirectAttributes.addAttribute("memberNo", memberNo);
        return "redirect:/admin/members";
    }

    @PostMapping("/{memberNo}/activate")
    public String activate(
            @PathVariable Long memberNo,
            RedirectAttributes redirectAttributes) {
        try {
            adminMemberService.activateMember(memberNo);
            redirectAttributes.addFlashAttribute("pageNotice", "회원 이용 정지를 해제했습니다.");
        } catch (IllegalArgumentException | IllegalStateException exception) {
            redirectAttributes.addFlashAttribute("pageError", exception.getMessage());
        }
        redirectAttributes.addAttribute("memberNo", memberNo);
        return "redirect:/admin/members";
    }
}
