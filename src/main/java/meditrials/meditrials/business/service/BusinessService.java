package meditrials.meditrials.business.service;

import meditrials.meditrials.business.vo.BusinessVO;

public interface BusinessService {

    int getBusinessCount();

    boolean isBusinessRegNoDuplicated(String businessRegNo);

    BusinessVO getBusinessByNo(Long businessNo);

    BusinessVO getBusinessByMemberNo(Long memberNo);

    BusinessVO registerBusiness(
            String email,
            String rawPassword,
            String memberName,
            String memberPhone,
            BusinessVO business);
}
