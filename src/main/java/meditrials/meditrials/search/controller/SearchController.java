package meditrials.meditrials.search.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import meditrials.meditrials.search.service.IntegratedSearchService;
import meditrials.meditrials.search.vo.IntegratedSearchVO;

@Controller
@RequestMapping("/search")
public class SearchController {

    private final IntegratedSearchService integratedSearchService;

    public SearchController(IntegratedSearchService integratedSearchService) {
        this.integratedSearchService = integratedSearchService;
    }

    @GetMapping
    public String search(
            @RequestParam(name = "keyword", defaultValue = "") String keyword,
            Model model) {

        IntegratedSearchVO result = integratedSearchService.search(keyword);
        model.addAttribute("searchResult", result);
        model.addAttribute("keyword", result.getKeyword());
        return "search/result";
    }
}
