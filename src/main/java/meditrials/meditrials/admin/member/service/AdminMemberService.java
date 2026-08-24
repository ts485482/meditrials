package meditrials.meditrials.admin.member.service;

import java.util.List;

import meditrials.meditrials.admin.member.vo.AdminMemberVO;

public interface AdminMemberService {

    List<AdminMemberVO> getMembers(String keyword);

    AdminMemberVO getMember(Long memberNo);

    int getActiveCount();

    int getSuspendedCount();

    int getWithdrawnCount();

    void suspendMember(Long memberNo);

    void activateMember(Long memberNo);
}
