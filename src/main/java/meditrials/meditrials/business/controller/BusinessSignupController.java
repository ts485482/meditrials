package meditrials.meditrials.business.controller;

import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import meditrials.meditrials.business.service.BusinessService;
import meditrials.meditrials.business.vo.BusinessVO;
import meditrials.meditrials.member.service.MemberService;

@Controller
@RequestMapping("/business")
public class BusinessSignupController {

    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");
    private static final Pattern ENGLISH_LETTER_PATTERN = Pattern.compile("[A-Za-z]");
    private static final String SPECIAL_CHARACTERS = "!@#$%^&*()_+-=[]{};:,.<>/?`~";
    private static final Set<String> ALLOWED_ORG_TYPES = Set.of(
            "HOSPITAL", "PHARMA", "RESEARCH", "CRO", "OTHER");

    private final MemberService memberService;
    private final BusinessService businessService;

    public BusinessSignupController(
            MemberService memberService,
            BusinessService businessService) {
        this.memberService = memberService;
        this.businessService = businessService;
    }

    @GetMapping("/signup")
    public String signupForm() {
        return "business/signup";
    }

    @GetMapping("/check-registration-no")
    @ResponseBody
    public Map<String, Object> checkRegistrationNo(
            @RequestParam(name = "businessRegNo", defaultValue = "") String businessRegNo) {

        if (businessRegNo.isBlank()) {
            return Map.of(
                    "available", false,
                    "message", "사업자등록번호를 입력해주세요.");
        }

        boolean duplicated = businessService.isBusinessRegNoDuplicated(businessRegNo);
        return Map.of(
                "available", !duplicated,
                "message", duplicated
                        ? "이미 등록된 사업자등록번호입니다."
                        : "사용 가능한 사업자등록번호입니다.");
    }

    @PostMapping("/signup")
    public String signup(
            @RequestParam(defaultValue = "") String email,
            @RequestParam(defaultValue = "") String password,
            @RequestParam(defaultValue = "") String passwordConfirm,
            @RequestParam(defaultValue = "") String memberName,
            @RequestParam(defaultValue = "") String memberPhone,
            @RequestParam(defaultValue = "") String orgName,
            @RequestParam(defaultValue = "") String orgType,
            @RequestParam(defaultValue = "") String businessRegNo,
            @RequestParam(defaultValue = "") String orgPhone,
            Model model) {

        String errorCode = validateSignup(
                email,
                password,
                passwordConfirm,
                memberName,
                memberPhone,
                orgName,
                orgType,
                businessRegNo,
                orgPhone);

        if (errorCode != null) {
            prepareFormModel(
                    model,
                    errorCode,
                    email,
                    memberName,
                    memberPhone,
                    orgName,
                    orgType,
                    businessRegNo,
                    orgPhone);
            return "business/signup";
        }

        if (memberService.isEmailDuplicated(email)) {
            prepareFormModel(
                    model,
                    "EMAIL_DUPLICATED",
                    email,
                    memberName,
                    memberPhone,
                    orgName,
                    orgType,
                    businessRegNo,
                    orgPhone);
            return "business/signup";
        }

        if (businessService.isBusinessRegNoDuplicated(businessRegNo)) {
            prepareFormModel(
                    model,
                    "BUSINESS_REG_NO_DUPLICATED",
                    email,
                    memberName,
                    memberPhone,
                    orgName,
                    orgType,
                    businessRegNo,
                    orgPhone);
            return "business/signup";
        }

        BusinessVO business = new BusinessVO();
        business.setOrgName(orgName);
        business.setOrgType(orgType);
        business.setBusinessRegNo(businessRegNo);
        business.setPhone(orgPhone);
        business.setEmail(email);

        try {
            businessService.registerBusiness(
                    email,
                    password,
                    memberName,
                    memberPhone,
                    business);
        } catch (DataIntegrityViolationException exception) {
            prepareFormModel(
                    model,
                    resolveIntegrityError(email, businessRegNo),
                    email,
                    memberName,
                    memberPhone,
                    orgName,
                    orgType,
                    businessRegNo,
                    orgPhone);
            return "business/signup";
        } catch (IllegalStateException exception) {
            String code = exception.getMessage();
            if ("EMAIL_DUPLICATED".equals(code) || "BUSINESS_REG_NO_DUPLICATED".equals(code)) {
                prepareFormModel(
                        model,
                        code,
                        email,
                        memberName,
                        memberPhone,
                        orgName,
                        orgType,
                        businessRegNo,
                        orgPhone);
                return "business/signup";
            }
            throw exception;
        }

        return "redirect:/login?businessSignup=success";
    }

    private String validateSignup(
            String email,
            String password,
            String passwordConfirm,
            String memberName,
            String memberPhone,
            String orgName,
            String orgType,
            String businessRegNo,
            String orgPhone) {

        if (email.isBlank()) {
            return "EMAIL_REQUIRED";
        }
        if (password.isBlank()) {
            return "PASSWORD_REQUIRED";
        }
        if (passwordConfirm.isBlank()) {
            return "PASSWORD_CONFIRM_REQUIRED";
        }
        if (memberName.isBlank()) {
            return "NAME_REQUIRED";
        }
        if (memberPhone.isBlank()) {
            return "MEMBER_PHONE_REQUIRED";
        }
        if (orgName.isBlank()) {
            return "ORG_NAME_REQUIRED";
        }
        if (orgType.isBlank()) {
            return "ORG_TYPE_REQUIRED";
        }
        if (businessRegNo.isBlank()) {
            return "BUSINESS_REG_NO_REQUIRED";
        }
        if (orgPhone.isBlank()) {
            return "ORG_PHONE_REQUIRED";
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
        if (!ALLOWED_ORG_TYPES.contains(orgType.trim().toUpperCase())) {
            return "ORG_TYPE_INVALID";
        }
        return null;
    }

    private boolean isValidPassword(String password) {
        if (password.length() < 8 || !ENGLISH_LETTER_PATTERN.matcher(password).find()) {
            return false;
        }

        return password.chars()
                .mapToObj(character -> String.valueOf((char) character))
                .anyMatch(SPECIAL_CHARACTERS::contains);
    }

    private String resolveIntegrityError(String email, String businessRegNo) {
        if (memberService.isEmailDuplicated(email)) {
            return "EMAIL_DUPLICATED";
        }
        if (businessService.isBusinessRegNoDuplicated(businessRegNo)) {
            return "BUSINESS_REG_NO_DUPLICATED";
        }
        return "SIGNUP_FAILED";
    }

    private void prepareFormModel(
            Model model,
            String errorCode,
            String email,
            String memberName,
            String memberPhone,
            String orgName,
            String orgType,
            String businessRegNo,
            String orgPhone) {

        model.addAttribute("errorCode", errorCode);
        model.addAttribute("email", trim(email));
        model.addAttribute("memberName", trim(memberName));
        model.addAttribute("memberPhone", trim(memberPhone));
        model.addAttribute("orgName", trim(orgName));
        model.addAttribute("orgType", trim(orgType));
        model.addAttribute("businessRegNo", trim(businessRegNo));
        model.addAttribute("orgPhone", trim(orgPhone));
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
