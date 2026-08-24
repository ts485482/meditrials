package meditrials.meditrials.support.service;

import java.util.List;

import meditrials.meditrials.support.vo.SupportNoticeVO;

public interface SupportService {

    List<SupportNoticeVO> getNotices(String keyword);

    int getNoticeCount(String keyword);

    SupportNoticeVO getNotice(Long noticeNo);
}
