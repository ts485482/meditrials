package meditrials.meditrials.business.controller;

import java.util.regex.Pattern;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.servlet.http.HttpSession;
import meditrials.meditrials.business.service.BusinessService;
import meditrials.meditrials.business.vo.BusinessVO;
import meditrials.meditrials.common.constant.SessionConstants;

@Controller
@RequestMapping("/business/profile")
public class BusinessProfileController {

    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");

    private static final int PHONE_MAX_LENGTH = 30;
    private static final int EMAIL_MAX_LENGTH = 200;
    private static final int ADDRESS_MAX_LENGTH = 500;
    private static final int DESCRIPTION_MAX_LENGTH = 1000;

    private final BusinessService businessService;

    public BusinessProfileController(BusinessService businessService) {
        this.businessService = businessService;
    }

    @GetMapping
    public String profile(
            @RequestParam(name = "updated", defaultValue = "false") boolean updated,
            HttpSession session,
            Model model) {

        Long memberNo = getLoginMemberNo(session);
        BusinessVO business = businessService.getBusinessByMemberNo(memberNo);
        if (business == null) {
            return "redirect:/business";
        }

        model.addAttribute("business", business);
        if (updated) {
            model.addAttribute("successMessage", "기관정보가 저장되었습니다.");
        }
        return "business/profile";
    }

    @PostMapping
    public String updateProfile(
            @RequestParam(name = "orgPhone", defaultValue = "") String orgPhone,
            @RequestParam(name = "orgEmail", defaultValue = "") String orgEmail,
            @RequestParam(name = "address", defaultValue = "") String address,
            @RequestParam(name = "description", defaultValue = "") String description,
            HttpSession session,
            Model model,
            RedirectAttributes redirectAttributes) {

        Long memberNo = getLoginMemberNo(session);
        BusinessVO business = businessService.getBusinessByMemberNo(memberNo);
        if (business == null) {
            return "redirect:/business";
        }

        String phone = trim(orgPhone);
        String email = trim(orgEmail);
        String normalizedAddress = trim(address);
        String normalizedDescription = trim(description);

        String errorMessage = validateProfile(phone, email, normalizedAddress, normalizedDescription);
        if (errorMessage != null) {
            business.setPhone(phone);
            business.setEmail(email);
            business.setAddress(normalizedAddress);
            business.setDescription(normalizedDescription);
            model.addAttribute("business", business);
            model.addAttribute("errorMessage", errorMessage);
            return "business/profile";
        }

        try {
            businessService.updateBusinessProfile(
                    memberNo,
                    phone,
                    email,
                    normalizedAddress,
                    normalizedDescription);
        } catch (IllegalArgumentException exception) {
            business.setPhone(phone);
            business.setEmail(email);
            business.setAddress(normalizedAddress);
            business.setDescription(normalizedDescription);
            model.addAttribute("business", business);
            model.addAttribute("errorMessage", "기관정보를 확인한 뒤 다시 저장해주세요.");
            return "business/profile";
        } catch (IllegalStateException exception) {
            redirectAttributes.addFlashAttribute("profileError", "기관정보를 저장하지 못했습니다. 잠시 후 다시 시도해주세요.");
            return "redirect:/business/profile";
        }

        return "redirect:/business/profile?updated=true";
    }

    private String validateProfile(
            String phone,
            String email,
            String address,
            String description) {

        if (phone.isBlank()) {
            return "기관 연락처를 입력해주세요.";
        }
        if (phone.length() > PHONE_MAX_LENGTH) {
            return "기관 연락처는 30자 이내로 입력해주세요.";
        }
        if (email.isBlank()) {
            return "기관 이메일을 입력해주세요.";
        }
        if (email.length() > EMAIL_MAX_LENGTH || !EMAIL_PATTERN.matcher(email).matches()) {
            return "올바른 기관 이메일을 입력해주세요.";
        }
        if (address.length() > ADDRESS_MAX_LENGTH) {
            return "주소는 500자 이내로 입력해주세요.";
        }
        if (description.length() > DESCRIPTION_MAX_LENGTH) {
            return "기관 소개는 1000자 이내로 입력해주세요.";
        }
        return null;
    }

    private Long getLoginMemberNo(HttpSession session) {
        Object value = session.getAttribute(SessionConstants.LOGIN_MEMBER_NO);
        return value instanceof Number number ? number.longValue() : null;
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
