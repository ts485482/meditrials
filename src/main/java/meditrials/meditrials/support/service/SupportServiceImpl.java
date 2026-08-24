package meditrials.meditrials.support.service;

import java.util.List;

import org.springframework.stereotype.Service;

import meditrials.meditrials.support.dao.SupportDAO;
import meditrials.meditrials.support.vo.SupportNoticeVO;

@Service
public class SupportServiceImpl implements SupportService {

    private static final int NOTICE_LIST_LIMIT = 30;

    private final SupportDAO supportDAO;

    public SupportServiceImpl(SupportDAO supportDAO) {
        this.supportDAO = supportDAO;
    }

    @Override
    public List<SupportNoticeVO> getNotices(String keyword) {
        return supportDAO.selectNoticeList(normalizeKeyword(keyword), NOTICE_LIST_LIMIT);
    }

    @Override
    public int getNoticeCount(String keyword) {
        return supportDAO.countNoticeList(normalizeKeyword(keyword));
    }

    @Override
    public SupportNoticeVO getNotice(Long noticeNo) {
        if (noticeNo == null) {
            return null;
        }
        return supportDAO.selectNoticeByNo(noticeNo);
    }

    private String normalizeKeyword(String keyword) {
        if (keyword == null || keyword.isBlank()) {
            return null;
        }
        String normalized = keyword.trim();
        return normalized.length() <= 100 ? normalized : normalized.substring(0, 100);
    }
}
