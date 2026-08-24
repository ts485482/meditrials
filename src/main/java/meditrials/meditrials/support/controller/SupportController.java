package meditrials.meditrials.support.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import meditrials.meditrials.support.service.SupportService;
import meditrials.meditrials.support.vo.SupportNoticeVO;

@Controller
@RequestMapping("/support")
public class SupportController {

    private final SupportService supportService;

    public SupportController(SupportService supportService) {
        this.supportService = supportService;
    }

    @GetMapping
    public String support(
            @RequestParam(name = "keyword", defaultValue = "") String keyword,
            @RequestParam(name = "notFound", defaultValue = "false") boolean notFound,
            Model model) {

        model.addAttribute("notices", supportService.getNotices(keyword));
        model.addAttribute("noticeCount", supportService.getNoticeCount(keyword));
        model.addAttribute("keyword", keyword == null ? "" : keyword.trim());
        if (notFound) {
            model.addAttribute("pageNotice", "요청한 공지사항을 찾을 수 없습니다.");
        }
        return "support/index";
    }

    @GetMapping("/notices/{noticeNo}")
    public String noticeDetail(
            @PathVariable Long noticeNo,
            Model model) {

        SupportNoticeVO notice = supportService.getNotice(noticeNo);
        if (notice == null) {
            return "redirect:/support?notFound=true";
        }
        model.addAttribute("notice", notice);
        return "support/notice-detail";
    }
}
