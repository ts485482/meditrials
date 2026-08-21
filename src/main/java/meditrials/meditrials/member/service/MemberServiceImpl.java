package meditrials.meditrials.member.service;

import java.util.Locale;

import org.springframework.stereotype.Service;

import meditrials.meditrials.member.dao.MemberDAO;
import meditrials.meditrials.member.vo.MemberVO;

@Service
public class MemberServiceImpl implements MemberService {

    private final MemberDAO memberMapper;

    public MemberServiceImpl(MemberDAO memberMapper) {
        this.memberMapper = memberMapper;
    }

    @Override
    public int getMemberCount() {
        return memberMapper.countMembers();
    }

    @Override
    public boolean isEmailDuplicated(String email) {
        if (email == null || email.isBlank()) {
            return false;
        }
        return memberMapper.countByEmail(email.trim().toLowerCase(Locale.ROOT)) > 0;
    }

    @Override
    public MemberVO getMemberByNo(Long memberNo) {
        return memberMapper.selectMemberByNo(memberNo);
    }

    @Override
    public MemberVO getMemberByEmail(String email) {
        if (email == null || email.isBlank()) {
            return null;
        }
        return memberMapper.selectMemberByEmail(email.trim().toLowerCase(Locale.ROOT));
    }
}
