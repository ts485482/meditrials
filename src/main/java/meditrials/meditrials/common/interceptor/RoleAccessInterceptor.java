package meditrials.meditrials.common.interceptor;

import java.io.IOException;

import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import meditrials.meditrials.common.constant.SessionConstants;

@Component
public class RoleAccessInterceptor implements HandlerInterceptor {

    private static final String ROLE_USER = "USER";
    private static final String ROLE_BUSINESS = "BUSINESS";
    private static final String ROLE_ADMIN = "ADMIN";

    @Override
    public boolean preHandle(
            HttpServletRequest request,
            HttpServletResponse response,
            Object handler) throws IOException {

        String roleCode = getLoginRole(request);
        if (roleCode == null) {
            response.sendRedirect(request.getContextPath() + "/login?required=true");
            return false;
        }

        String requestPath = getRequestPath(request);
        String requiredRole = resolveRequiredRole(requestPath);

        if (requiredRole != null && !requiredRole.equals(roleCode)) {
            redirectToRoleHome(response, request.getContextPath(), roleCode);
            return false;
        }

        return true;
    }

    private String getLoginRole(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }

        Object role = session.getAttribute(SessionConstants.LOGIN_MEMBER_ROLE);
        return role instanceof String ? (String) role : null;
    }

    private String getRequestPath(HttpServletRequest request) {
        String requestUri = request.getRequestURI();
        String contextPath = request.getContextPath();

        if (!contextPath.isEmpty() && requestUri.startsWith(contextPath)) {
            return requestUri.substring(contextPath.length());
        }
        return requestUri;
    }

    private String resolveRequiredRole(String requestPath) {
        if (requestPath.startsWith("/admin")) {
            return ROLE_ADMIN;
        }
        if (requestPath.startsWith("/business")) {
            return ROLE_BUSINESS;
        }
        if (requestPath.startsWith("/mypage") || isTrialInquiryPath(requestPath)) {
            return ROLE_USER;
        }
        return null;
    }

    private boolean isTrialInquiryPath(String requestPath) {
        return requestPath.startsWith("/trials/") && requestPath.contains("/inquiries/");
    }

    private void redirectToRoleHome(
            HttpServletResponse response,
            String contextPath,
            String roleCode) throws IOException {

        if (ROLE_ADMIN.equals(roleCode)) {
            response.sendRedirect(contextPath + "/admin");
            return;
        }
        if (ROLE_BUSINESS.equals(roleCode)) {
            response.sendRedirect(contextPath + "/business");
            return;
        }
        response.sendRedirect(contextPath + "/main");
    }
}
