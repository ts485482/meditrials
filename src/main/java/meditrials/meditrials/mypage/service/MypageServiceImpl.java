package meditrials.meditrials.mypage.service;

import java.util.List;
import java.util.regex.Pattern;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import meditrials.meditrials.member.vo.MemberVO;
import meditrials.meditrials.mypage.dao.MypageDAO;
import meditrials.meditrials.mypage.vo.MypageRecentItemVO;
import meditrials.meditrials.mypage.vo.MypageSummaryVO;

@Service
public class MypageServiceImpl implements MypageService {

    private static final Pattern ENGLISH_LETTER_PATTERN = Pattern.compile("[A-Za-z]");
    private static final String SPECIAL_CHARACTERS = "!@#$%^&*()_+-=[]{};:,.<>/?`~";
    private static final int MEMBER_NAME_MAX_LENGTH = 100;
    private static final int PHONE_MAX_LENGTH = 30;

    private final MypageDAO mypageDAO;
    private final PasswordEncoder passwordEncoder;

    public MypageServiceImpl(MypageDAO mypageDAO, PasswordEncoder passwordEncoder) {
        this.mypageDAO = mypageDAO;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public MypageSummaryVO getSummary(Long memberNo) {
        if (memberNo == null) {
            return new MypageSummaryVO();
        }
        MypageSummaryVO summary = mypageDAO.selectSummary(memberNo);
        return summary == null ? new MypageSummaryVO() : summary;
    }

    @Override
    public List<MypageRecentItemVO> getRecentFavoriteDiseases(Long memberNo) {
        return memberNo == null ? List.of() : mypageDAO.selectRecentFavoriteDiseases(memberNo);
    }

    @Override
    public List<MypageRecentItemVO> getRecentFavoriteTrials(Long memberNo) {
        return memberNo == null ? List.of() : mypageDAO.selectRecentFavoriteTrials(memberNo);
    }

    @Override
    public List<MypageRecentItemVO> getRecentInquiries(Long memberNo) {
        return memberNo == null ? List.of() : mypageDAO.selectRecentInquiries(memberNo);
    }

    @Override
    public MemberVO getMemberProfile(Long memberNo) {
        if (memberNo == null) {
            return null;
        }
        return mypageDAO.selectMemberProfile(memberNo);
    }

    @Override
    @Transactional
    public MemberVO updateMemberProfile(Long memberNo, String memberName, String phone) {
        if (memberNo == null) {
            throw new IllegalArgumentException("회원 정보를 확인할 수 없습니다.");
        }

        String normalizedName = normalize(memberName);
        String normalizedPhone = normalize(phone);

        if (normalizedName.isEmpty()) {
            throw new IllegalArgumentException("이름을 입력해주세요.");
        }
        if (normalizedName.length() > MEMBER_NAME_MAX_LENGTH) {
            throw new IllegalArgumentException("이름은 100자 이내로 입력해주세요.");
        }
        if (normalizedPhone.isEmpty()) {
            throw new IllegalArgumentException("연락처를 입력해주세요.");
        }
        if (normalizedPhone.length() > PHONE_MAX_LENGTH) {
            throw new IllegalArgumentException("연락처는 30자 이내로 입력해주세요.");
        }

        if (mypageDAO.updateMemberProfile(memberNo, normalizedName, normalizedPhone) != 1) {
            throw new IllegalStateException("회원정보를 수정하지 못했습니다.");
        }

        return mypageDAO.selectMemberProfile(memberNo);
    }

    @Override
    @Transactional
    public void changePassword(
            Long memberNo,
            String currentPassword,
            String newPassword,
            String passwordConfirm) {

        if (memberNo == null) {
            throw new IllegalArgumentException("회원 정보를 확인할 수 없습니다.");
        }
        if (isBlank(currentPassword)) {
            throw new IllegalArgumentException("현재 비밀번호를 입력해주세요.");
        }
        if (isBlank(newPassword)) {
            throw new IllegalArgumentException("새 비밀번호를 입력해주세요.");
        }
        if (isBlank(passwordConfirm)) {
            throw new IllegalArgumentException("새 비밀번호 확인을 입력해주세요.");
        }
        if (!isValidPassword(newPassword)) {
            throw new IllegalArgumentException("새 비밀번호는 8자 이상이며 영문자와 특수문자를 포함해야 합니다.");
        }
        if (!newPassword.equals(passwordConfirm)) {
            throw new IllegalArgumentException("새 비밀번호와 비밀번호 확인이 일치하지 않습니다.");
        }
        if (currentPassword.equals(newPassword)) {
            throw new IllegalArgumentException("새 비밀번호는 현재 비밀번호와 다르게 입력해주세요.");
        }

        MemberVO member = mypageDAO.selectMemberProfile(memberNo);
        if (member == null || member.getPasswordHash() == null
                || !passwordEncoder.matches(currentPassword, member.getPasswordHash())) {
            throw new IllegalArgumentException("현재 비밀번호가 일치하지 않습니다.");
        }

        String encodedPassword = passwordEncoder.encode(newPassword);
        if (mypageDAO.updatePasswordHash(memberNo, encodedPassword) != 1) {
            throw new IllegalStateException("비밀번호를 변경하지 못했습니다.");
        }
    }

    private boolean isValidPassword(String password) {
        if (password.length() < 8 || !ENGLISH_LETTER_PATTERN.matcher(password).find()) {
            return false;
        }
        return password.chars()
                .mapToObj(character -> (char) character)
                .anyMatch(character -> SPECIAL_CHARACTERS.indexOf(character) >= 0);
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim();
    }
}
