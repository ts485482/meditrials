package meditrials.meditrials.admin.business.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.servlet.http.HttpSession;
import meditrials.meditrials.admin.business.service.AdminBusinessService;
import meditrials.meditrials.business.vo.BusinessVO;
import meditrials.meditrials.common.constant.SessionConstants;

@Controller
@RequestMapping("/admin/businesses")
public class AdminBusinessController {

    private final AdminBusinessService adminBusinessService;

    public AdminBusinessController(AdminBusinessService adminBusinessService) {
        this.adminBusinessService = adminBusinessService;
    }

    @GetMapping
    public String businesses(
            @RequestParam(name = "businessNo", required = false) Long businessNo,
            Model model) {

        List<BusinessVO> businesses = adminBusinessService.getBusinesses();
        BusinessVO selectedBusiness = resolveSelectedBusiness(businessNo, businesses);

        model.addAttribute("businesses", businesses);
        model.addAttribute("selectedBusiness", selectedBusiness);
        model.addAttribute("pendingCount", countByStatus(businesses, "PENDING"));
        model.addAttribute("approvedCount", countByStatus(businesses, "APPROVED"));
        model.addAttribute("rejectedCount", countByStatus(businesses, "REJECTED"));
        return "admin/businesses";
    }

    @PostMapping("/{businessNo}/approve")
    public String approve(
            @PathVariable Long businessNo,
            HttpSession session,
            RedirectAttributes redirectAttributes) {

        try {
            adminBusinessService.approveBusiness(getLoginMemberNo(session), businessNo);
            redirectAttributes.addFlashAttribute("pageNotice", "사업자 승인이 완료되었습니다.");
        } catch (IllegalArgumentException exception) {
            redirectAttributes.addFlashAttribute("pageError", exception.getMessage());
        } catch (IllegalStateException exception) {
            redirectAttributes.addFlashAttribute(
                    "pageError",
                    "이미 승인 또는 반려 처리된 사업자입니다.");
        }
        return "redirect:/admin/businesses?businessNo=" + businessNo;
    }

    @PostMapping("/{businessNo}/reject")
    public String reject(
            @PathVariable Long businessNo,
            @RequestParam(name = "rejectReason", defaultValue = "") String rejectReason,
            HttpSession session,
            RedirectAttributes redirectAttributes) {

        try {
            adminBusinessService.rejectBusiness(
                    getLoginMemberNo(session),
                    businessNo,
                    rejectReason);
            redirectAttributes.addFlashAttribute("pageNotice", "사업자 신청을 반려했습니다.");
        } catch (IllegalArgumentException exception) {
            redirectAttributes.addFlashAttribute("pageError", exception.getMessage());
        } catch (IllegalStateException exception) {
            redirectAttributes.addFlashAttribute(
                    "pageError",
                    "이미 승인 또는 반려 처리된 사업자입니다.");
        }
        return "redirect:/admin/businesses?businessNo=" + businessNo;
    }

    private BusinessVO resolveSelectedBusiness(
            Long businessNo,
            List<BusinessVO> businesses) {

        if (businessNo != null) {
            BusinessVO selected = adminBusinessService.getBusiness(businessNo);
            if (selected != null) {
                return selected;
            }
        }

        return businesses.stream()
                .filter(business -> "PENDING".equals(business.getApprovalStatus()))
                .findFirst()
                .orElse(businesses.isEmpty() ? null : businesses.get(0));
    }

    private long countByStatus(List<BusinessVO> businesses, String status) {
        return businesses.stream()
                .filter(business -> status.equals(business.getApprovalStatus()))
                .count();
    }

    private Long getLoginMemberNo(HttpSession session) {
        Object value = session.getAttribute(SessionConstants.LOGIN_MEMBER_NO);
        return value instanceof Number number ? number.longValue() : null;
    }
}
