package meditrials.meditrials.favorite.controller;

import java.util.Locale;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import meditrials.meditrials.common.constant.SessionConstants;
import meditrials.meditrials.favorite.service.FavoriteService;

@Controller
@RequestMapping("/mypage/favorites")
public class FavoriteController {

    private static final String TAB_DISEASES = "diseases";
    private static final String TAB_TRIALS = "trials";

    private final FavoriteService favoriteService;

    public FavoriteController(FavoriteService favoriteService) {
        this.favoriteService = favoriteService;
    }

    @GetMapping
    public String favoriteList(
            @RequestParam(name = "tab", defaultValue = TAB_DISEASES) String tab,
            HttpServletRequest request,
            Model model) {

        Long memberNo = getLoginMemberNo(request);
        if (memberNo == null) {
            return "redirect:/login?required=true";
        }

        String selectedTab = normalizeTab(tab);
        model.addAttribute("selectedTab", selectedTab);
        model.addAttribute("favoriteDiseases", favoriteService.getFavoriteDiseases(memberNo));
        model.addAttribute("favoriteTrials", favoriteService.getFavoriteTrials(memberNo));
        return "mypage/favorites";
    }

    @PostMapping("/diseases/{diseaseNo}")
    public String toggleDiseaseFavorite(
            @PathVariable Long diseaseNo,
            @RequestParam(name = "returnTo", defaultValue = "detail") String returnTo,
            HttpServletRequest request) {

        Long memberNo = getLoginMemberNo(request);
        if (memberNo == null) {
            return "redirect:/login?required=true";
        }

        favoriteService.toggleDiseaseFavorite(memberNo, diseaseNo);
        if ("list".equalsIgnoreCase(returnTo)) {
            return "redirect:/mypage/favorites?tab=diseases";
        }
        return "redirect:/diseases/" + diseaseNo;
    }

    @PostMapping("/trials/{trialNo}")
    public String toggleTrialFavorite(
            @PathVariable Long trialNo,
            @RequestParam(name = "returnTo", defaultValue = "detail") String returnTo,
            HttpServletRequest request) {

        Long memberNo = getLoginMemberNo(request);
        if (memberNo == null) {
            return "redirect:/login?required=true";
        }

        favoriteService.toggleTrialFavorite(memberNo, trialNo);
        if ("list".equalsIgnoreCase(returnTo)) {
            return "redirect:/mypage/favorites?tab=trials";
        }
        return "redirect:/trials/" + trialNo;
    }

    private String normalizeTab(String tab) {
        if (tab == null) {
            return TAB_DISEASES;
        }
        String normalized = tab.trim().toLowerCase(Locale.ROOT);
        return TAB_TRIALS.equals(normalized) ? TAB_TRIALS : TAB_DISEASES;
    }

    private Long getLoginMemberNo(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }

        Object memberNo = session.getAttribute(SessionConstants.LOGIN_MEMBER_NO);
        if (memberNo instanceof Number number) {
            return number.longValue();
        }
        return null;
    }
}
