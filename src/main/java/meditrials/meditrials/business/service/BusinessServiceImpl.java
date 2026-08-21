package meditrials.meditrials.business.service;

import org.springframework.stereotype.Service;

import meditrials.meditrials.business.dao.BusinessDAO;
import meditrials.meditrials.business.vo.BusinessVO;

@Service
public class BusinessServiceImpl implements BusinessService {

    private final BusinessDAO businessDAO;

    public BusinessServiceImpl(BusinessDAO businessDAO) {
        this.businessDAO = businessDAO;
    }

    @Override
    public int getBusinessCount() {
        return businessDAO.countBusinesses();
    }

    @Override
    public boolean isBusinessRegNoDuplicated(String businessRegNo) {
        if (businessRegNo == null || businessRegNo.isBlank()) {
            return false;
        }
        return businessDAO.countByBusinessRegNo(businessRegNo.trim()) > 0;
    }

    @Override
    public BusinessVO getBusinessByNo(Long businessNo) {
        return businessDAO.selectBusinessByNo(businessNo);
    }

    @Override
    public BusinessVO getBusinessByMemberNo(Long memberNo) {
        return businessDAO.selectBusinessByMemberNo(memberNo);
    }
}
