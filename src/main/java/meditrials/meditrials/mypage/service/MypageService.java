package meditrials.meditrials.mypage.service;

import java.util.List;

import meditrials.meditrials.member.vo.MemberVO;
import meditrials.meditrials.mypage.vo.MypageRecentItemVO;
import meditrials.meditrials.mypage.vo.MypageSummaryVO;

public interface MypageService {

    MypageSummaryVO getSummary(Long memberNo);

    List<MypageRecentItemVO> getRecentFavoriteDiseases(Long memberNo);

    List<MypageRecentItemVO> getRecentFavoriteTrials(Long memberNo);

    List<MypageRecentItemVO> getRecentInquiries(Long memberNo);

    MemberVO getMemberProfile(Long memberNo);

    MemberVO updateMemberProfile(Long memberNo, String memberName, String phone);

    void changePassword(Long memberNo, String currentPassword, String newPassword, String passwordConfirm);
}
