package meditrials.meditrials.business.trial.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import meditrials.meditrials.business.dao.BusinessDAO;
import meditrials.meditrials.business.trial.dao.BusinessTrialDAO;
import meditrials.meditrials.business.trial.vo.BusinessTrialVO;
import meditrials.meditrials.business.vo.BusinessVO;
import meditrials.meditrials.disease.dao.DiseaseDAO;
import meditrials.meditrials.disease.vo.DiseaseVO;

@Service
public class BusinessTrialServiceImpl implements BusinessTrialService {

    private static final String APPROVED = "APPROVED";
    private static final String ACTION_REVIEW = "review";

    private final BusinessTrialDAO businessTrialDAO;
    private final BusinessDAO businessDAO;
    private final DiseaseDAO diseaseDAO;

    public BusinessTrialServiceImpl(
            BusinessTrialDAO businessTrialDAO,
            BusinessDAO businessDAO,
            DiseaseDAO diseaseDAO) {
        this.businessTrialDAO = businessTrialDAO;
        this.businessDAO = businessDAO;
        this.diseaseDAO = diseaseDAO;
    }

    @Override
    public List<BusinessTrialVO> getBusinessTrials(Long memberNo) {
        BusinessVO business = getBusiness(memberNo);
        if (business == null) {
            return List.of();
        }
        return businessTrialDAO.selectBusinessTrialList(business.getBusinessNo());
    }

    @Override
    public BusinessTrialVO getBusinessTrial(Long memberNo, Long trialNo) {
        if (trialNo == null) {
            return null;
        }

        BusinessVO business = getBusiness(memberNo);
        if (business == null) {
            return null;
        }

        return businessTrialDAO.selectBusinessTrialByNo(trialNo, business.getBusinessNo());
    }

    @Override
    public List<DiseaseVO> getDiseaseOptions() {
        return diseaseDAO.selectDiseaseList(null, null, 100);
    }

    @Override
    public boolean canManageTrials(Long memberNo) {
        BusinessVO business = getBusiness(memberNo);
        return business != null && APPROVED.equals(business.getApprovalStatus());
    }

    @Override
    @Transactional
    public Long saveBusinessTrial(Long memberNo, BusinessTrialVO trial, String action) {
        BusinessVO business = getBusiness(memberNo);
        if (business == null) {
            throw new IllegalStateException("사업자 기관 정보를 확인할 수 없습니다.");
        }
        if (!APPROVED.equals(business.getApprovalStatus())) {
            throw new IllegalStateException("관리자 승인 완료 후 임상시험을 등록하거나 수정할 수 있습니다.");
        }
        if (trial == null) {
            throw new IllegalArgumentException("임상시험 입력정보를 확인해주세요.");
        }

        boolean requestReview = ACTION_REVIEW.equalsIgnoreCase(action);
        normalizeTrial(trial, business, requestReview);
        validateTrial(trial, requestReview);

        if (trial.getTrialNo() == null) {
            businessTrialDAO.insertBusinessTrial(trial);
        } else {
            BusinessTrialVO ownedTrial = businessTrialDAO.selectBusinessTrialByNo(
                    trial.getTrialNo(), business.getBusinessNo());
            if (ownedTrial == null) {
                throw new IllegalArgumentException("수정할 임상시험을 찾을 수 없거나 수정 권한이 없습니다.");
            }
            businessTrialDAO.updateBusinessTrial(trial);
        }

        businessTrialDAO.deleteTrialDisease(trial.getTrialNo());
        if (trial.getDiseaseNo() != null) {
            businessTrialDAO.insertTrialDisease(trial.getTrialNo(), trial.getDiseaseNo());
        }

        return trial.getTrialNo();
    }

    private BusinessVO getBusiness(Long memberNo) {
        if (memberNo == null) {
            return null;
        }
        return businessDAO.selectBusinessByMemberNo(memberNo);
    }

    private void normalizeTrial(
            BusinessTrialVO trial,
            BusinessVO business,
            boolean requestReview) {

        trial.setBusinessNo(business.getBusinessNo());
        trial.setTitle(trimToNull(trial.getTitle()));
        trial.setPhase(trimToNull(trial.getPhase()));
        trial.setRecruitmentStatus(trimToNull(trial.getRecruitmentStatus()));
        trial.setBriefSummary(trimToNull(trial.getBriefSummary()));
        trial.setEligibilityText(trimToNull(trial.getEligibilityText()));
        trial.setInstitutionName(trimToNull(trial.getInstitutionName()));
        trial.setStartDateText(trimToNull(trial.getStartDateText()));
        trial.setCompletionDateText(trimToNull(trial.getCompletionDateText()));
        trial.setContactPhone(trimToNull(trial.getContactPhone()));

        String orgName = trimToNull(business.getOrgName());
        if (trial.getInstitutionName() == null) {
            trial.setInstitutionName(orgName);
        }
        trial.setLocationText(trimToNull(business.getAddress()));
        trial.setContactEmail(trimToNull(business.getEmail()));
        trial.setReviewStatus(requestReview ? "PENDING" : "DRAFT");
    }

    private void validateTrial(BusinessTrialVO trial, boolean requestReview) {
        if (trial.getTitle() == null) {
            throw new IllegalArgumentException("임상시험 제목을 입력해주세요.");
        }

        if (!requestReview) {
            return;
        }

        if (trial.getDiseaseNo() == null) {
            throw new IllegalArgumentException("대상 질환을 선택해주세요.");
        }
        if (trial.getPhase() == null) {
            throw new IllegalArgumentException("임상 단계를 선택해주세요.");
        }
        if (trial.getRecruitmentStatus() == null) {
            throw new IllegalArgumentException("모집 상태를 선택해주세요.");
        }
        if (trial.getBriefSummary() == null) {
            throw new IllegalArgumentException("연구 목적을 입력해주세요.");
        }
        if (trial.getEligibilityText() == null) {
            throw new IllegalArgumentException("참여 조건을 입력해주세요.");
        }
        if (trial.getEnrollmentTarget() == null || trial.getEnrollmentTarget() <= 0) {
            throw new IllegalArgumentException("모집 인원은 1명 이상으로 입력해주세요.");
        }
        if (trial.getInstitutionName() == null) {
            throw new IllegalArgumentException("연구 기관을 입력해주세요.");
        }
        if (trial.getStartDateText() == null || trial.getCompletionDateText() == null) {
            throw new IllegalArgumentException("연구 기간의 시작일과 종료일을 입력해주세요.");
        }
        if (trial.getStartDateText().compareTo(trial.getCompletionDateText()) > 0) {
            throw new IllegalArgumentException("연구 종료일은 시작일보다 빠를 수 없습니다.");
        }
        if (trial.getContactPhone() == null) {
            throw new IllegalArgumentException("연락처를 입력해주세요.");
        }
    }

    private String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
