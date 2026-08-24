package meditrials.meditrials.business.common;

import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import jakarta.servlet.http.HttpSession;
import meditrials.meditrials.business.subscription.service.BusinessSubscriptionService;
import meditrials.meditrials.common.constant.SessionConstants;

/** 사업자 공통 사이드바에 현재 PREMIUM 활성 여부를 제공한다. */
@ControllerAdvice(basePackages = {
        "meditrials.meditrials.business",
        "meditrials.meditrials.inquiry"
})
public class BusinessNavigationAdvice {

    private final BusinessSubscriptionService businessSubscriptionService;

    public BusinessNavigationAdvice(BusinessSubscriptionService businessSubscriptionService) {
        this.businessSubscriptionService = businessSubscriptionService;
    }

    @ModelAttribute("businessPremiumActive")
    public boolean businessPremiumActive(HttpSession session) {
        Object role = session.getAttribute(SessionConstants.LOGIN_MEMBER_ROLE);
        if (!"BUSINESS".equals(role)) {
            return false;
        }

        Object memberNoValue = session.getAttribute(SessionConstants.LOGIN_MEMBER_NO);
        if (!(memberNoValue instanceof Number number)) {
            return false;
        }

        return businessSubscriptionService.isPremiumActive(number.longValue());
    }
}
