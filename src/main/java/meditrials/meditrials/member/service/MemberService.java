package meditrials.meditrials.member.service;

import meditrials.meditrials.member.vo.MemberVO;

public interface MemberService {

    int getMemberCount();

    boolean isEmailDuplicated(String email);

    MemberVO getMemberByNo(Long memberNo);

    MemberVO getMemberByEmail(String email);

    MemberVO registerUser(String email, String rawPassword, String memberName, String phone);
}
