package meditrials.meditrials.mypage.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import meditrials.meditrials.member.vo.MemberVO;
import meditrials.meditrials.mypage.vo.MypageRecentItemVO;
import meditrials.meditrials.mypage.vo.MypageSummaryVO;

@Mapper
public interface MypageDAO {

    MypageSummaryVO selectSummary(@Param("memberNo") Long memberNo);

    List<MypageRecentItemVO> selectRecentFavoriteDiseases(@Param("memberNo") Long memberNo);

    List<MypageRecentItemVO> selectRecentFavoriteTrials(@Param("memberNo") Long memberNo);

    List<MypageRecentItemVO> selectRecentInquiries(@Param("memberNo") Long memberNo);

    MemberVO selectMemberProfile(@Param("memberNo") Long memberNo);

    int updateMemberProfile(
            @Param("memberNo") Long memberNo,
            @Param("memberName") String memberName,
            @Param("phone") String phone);

    int updatePasswordHash(
            @Param("memberNo") Long memberNo,
            @Param("passwordHash") String passwordHash);
}
