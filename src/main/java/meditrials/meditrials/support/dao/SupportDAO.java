package meditrials.meditrials.support.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import meditrials.meditrials.support.vo.SupportNoticeVO;

@Mapper
public interface SupportDAO {

    List<SupportNoticeVO> selectNoticeList(
            @Param("keyword") String keyword,
            @Param("limit") int limit);

    int countNoticeList(@Param("keyword") String keyword);

    SupportNoticeVO selectNoticeByNo(@Param("noticeNo") Long noticeNo);
}
