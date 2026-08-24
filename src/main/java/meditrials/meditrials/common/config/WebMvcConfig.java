package meditrials.meditrials.common.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import meditrials.meditrials.common.interceptor.RoleAccessInterceptor;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    private final RoleAccessInterceptor roleAccessInterceptor;

    public WebMvcConfig(RoleAccessInterceptor roleAccessInterceptor) {
        this.roleAccessInterceptor = roleAccessInterceptor;
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(roleAccessInterceptor)
                .addPathPatterns(
                        "/mypage/**",
                        "/business/**",
                        "/admin/**",
                        "/trials/*/inquiries/**")
                .excludePathPatterns(
                        "/business/signup",
                        "/business/check-registration-no");
    }
}
