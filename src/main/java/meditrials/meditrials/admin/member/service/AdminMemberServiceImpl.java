package meditrials.meditrials.admin.member.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import meditrials.meditrials.admin.member.dao.AdminMemberDAO;
import meditrials.meditrials.admin.member.vo.AdminMemberVO;

@Service
public class AdminMemberServiceImpl implements AdminMemberService {

    private static final String ROLE_ADMIN = "ADMIN";
    private static final String STATUS_ACTIVE = "ACTIVE";
    private static final String STATUS_SUSPENDED = "SUSPENDED";
    private static final String STATUS_WITHDRAWN = "WITHDRAWN";

    private final AdminMemberDAO adminMemberDAO;

    public AdminMemberServiceImpl(AdminMemberDAO adminMemberDAO) {
        this.adminMemberDAO = adminMemberDAO;
    }

    @Override
    public List<AdminMemberVO> getMembers(String keyword) {
        return adminMemberDAO.selectMembers(normalizeKeyword(keyword));
    }

    @Override
    public AdminMemberVO getMember(Long memberNo) {
        if (memberNo == null) {
            return null;
        }
        return adminMemberDAO.selectMemberByNo(memberNo);
    }

    @Override
    public int getActiveCount() {
        return adminMemberDAO.countByStatus(STATUS_ACTIVE);
    }

    @Override
    public int getSuspendedCount() {
        return adminMemberDAO.countByStatus(STATUS_SUSPENDED);
    }

    @Override
    public int getWithdrawnCount() {
        return adminMemberDAO.countByStatus(STATUS_WITHDRAWN);
    }

    @Override
    @Transactional
    public void suspendMember(Long memberNo) {
        AdminMemberVO member = requireManageableMember(memberNo);
        if (STATUS_SUSPENDED.equals(member.getStatus())) {
            return;
        }
        if (!STATUS_ACTIVE.equals(member.getStatus())) {
            throw new IllegalStateException("현재 상태에서는 이용 정지할 수 없습니다.");
        }

        int updatedRows = adminMemberDAO.updateMemberStatus(memberNo, STATUS_SUSPENDED);
        if (updatedRows != 1) {
            throw new IllegalStateException("회원 이용 정지 처리에 실패했습니다.");
        }
    }

    @Override
    @Transactional
    public void activateMember(Long memberNo) {
        AdminMemberVO member = requireManageableMember(memberNo);
        if (STATUS_ACTIVE.equals(member.getStatus())) {
            return;
        }
        if (!STATUS_SUSPENDED.equals(member.getStatus())) {
            throw new IllegalStateException("정지된 회원만 이용 정지를 해제할 수 있습니다.");
        }

        int updatedRows = adminMemberDAO.updateMemberStatus(memberNo, STATUS_ACTIVE);
        if (updatedRows != 1) {
            throw new IllegalStateException("회원 이용 정지 해제에 실패했습니다.");
        }
    }

    private AdminMemberVO requireManageableMember(Long memberNo) {
        if (memberNo == null) {
            throw new IllegalArgumentException("회원 번호가 필요합니다.");
        }

        AdminMemberVO member = adminMemberDAO.selectMemberByNo(memberNo);
        if (member == null) {
            throw new IllegalArgumentException("회원을 찾을 수 없습니다.");
        }
        if (ROLE_ADMIN.equals(member.getRoleCode())) {
            throw new IllegalStateException("관리자 계정은 회원 관리 화면에서 정지할 수 없습니다.");
        }
        if (STATUS_WITHDRAWN.equals(member.getStatus())) {
            throw new IllegalStateException("탈퇴 회원의 상태는 변경할 수 없습니다.");
        }
        return member;
    }

    private String normalizeKeyword(String keyword) {
        if (keyword == null || keyword.isBlank()) {
            return null;
        }
        return keyword.trim();
    }
}
