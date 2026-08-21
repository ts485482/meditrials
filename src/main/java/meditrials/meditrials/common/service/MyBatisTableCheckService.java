package meditrials.meditrials.common.service;

import java.util.LinkedHashMap;
import java.util.Map;

import org.springframework.stereotype.Service;

import meditrials.meditrials.business.dao.BusinessDAO;
import meditrials.meditrials.business.vo.BusinessVO;
import meditrials.meditrials.member.dao.MemberDAO;
import meditrials.meditrials.member.vo.MemberVO;

@Service
public class MyBatisTableCheckService {

    private final MemberDAO memberDAO;
    private final BusinessDAO businessDAO;

    public MyBatisTableCheckService(MemberDAO memberDAO, BusinessDAO businessDAO) {
        this.memberDAO = memberDAO;
        this.businessDAO = businessDAO;
    }

    /**
     * 실제 MyBatis Mapper XML을 통해 MEMBER/BUSINESS를 조회한다.
     * 진단 응답에는 비밀번호 해시 등 민감한 값은 포함하지 않는다.
     */
    public Map<String, Object> check() {
        Map<String, Object> result = new LinkedHashMap<>();

        try {
            int memberCount = memberDAO.countMembers();
            int businessCount = businessDAO.countBusinesses();
            int linkedCount = businessDAO.countMemberBusinessLinks();

            result.put("mybatis", true);
            result.put("message", "MyBatis와 MEMBER/BUSINESS 테이블 연동에 성공했습니다.");
            result.put("memberCount", memberCount);
            result.put("businessCount", businessCount);
            result.put("memberBusinessLinkedCount", linkedCount);

            if (memberCount > 0) {
                MemberVO member = memberDAO.selectLatestMember();
                result.put("latestMember", toSafeMember(member));
            }

            if (businessCount > 0) {
                BusinessVO business = businessDAO.selectLatestBusiness();
                result.put("latestBusiness", toSafeBusiness(business));
            }
        } catch (RuntimeException ex) {
            result.put("mybatis", false);
            result.put("message", "MyBatis 또는 MEMBER/BUSINESS 테이블 연동에 실패했습니다.");
            result.put("error", getRootMessage(ex));
        }

        return result;
    }

    private Map<String, Object> toSafeMember(MemberVO member) {
        Map<String, Object> safe = new LinkedHashMap<>();
        if (member == null) {
            return safe;
        }

        safe.put("memberNo", member.getMemberNo());
        safe.put("email", member.getEmail());
        safe.put("memberName", member.getMemberName());
        safe.put("roleCode", member.getRoleCode());
        safe.put("status", member.getStatus());
        return safe;
    }

    private Map<String, Object> toSafeBusiness(BusinessVO business) {
        Map<String, Object> safe = new LinkedHashMap<>();
        if (business == null) {
            return safe;
        }

        safe.put("businessNo", business.getBusinessNo());
        safe.put("memberNo", business.getMemberNo());
        safe.put("orgName", business.getOrgName());
        safe.put("orgType", business.getOrgType());
        safe.put("approvalStatus", business.getApprovalStatus());
        return safe;
    }

    private String getRootMessage(Throwable throwable) {
        Throwable current = throwable;
        while (current.getCause() != null) {
            current = current.getCause();
        }

        String message = current.getMessage();
        return message == null || message.isBlank()
                ? current.getClass().getSimpleName()
                : message;
    }
}
