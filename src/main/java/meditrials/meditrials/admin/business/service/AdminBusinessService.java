package meditrials.meditrials.admin.business.service;

import java.util.List;

import meditrials.meditrials.business.vo.BusinessVO;

public interface AdminBusinessService {

    List<BusinessVO> getBusinesses();

    BusinessVO getBusiness(Long businessNo);

    void approveBusiness(Long adminMemberNo, Long businessNo);

    void rejectBusiness(Long adminMemberNo, Long businessNo, String rejectReason);
}
