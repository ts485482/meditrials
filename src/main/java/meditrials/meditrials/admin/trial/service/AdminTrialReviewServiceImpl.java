package meditrials.meditrials.admin.trial.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import meditrials.meditrials.admin.trial.dao.AdminTrialReviewDAO;
import meditrials.meditrials.admin.trial.vo.AdminTrialReviewVO;

@Service
public class AdminTrialReviewServiceImpl implements AdminTrialReviewService {

    private static final String PENDING = "PENDING";

    private final AdminTrialReviewDAO adminTrialReviewDAO;

    public AdminTrialReviewServiceImpl(AdminTrialReviewDAO adminTrialReviewDAO) {
        this.adminTrialReviewDAO = adminTrialReviewDAO;
    }

    @Override
    public List<AdminTrialReviewVO> getReviewTrials() {
        return adminTrialReviewDAO.selectReviewTrialList();
    }

    @Override
    public AdminTrialReviewVO getReviewTrial(Long trialNo) {
        if (trialNo == null) {
            return null;
        }
        return adminTrialReviewDAO.selectReviewTrialByNo(trialNo);
    }

    @Override
    @Transactional
    public void approveTrial(Long adminMemberNo, Long trialNo) {
        validateAdminAndTrial(adminMemberNo, trialNo);
        AdminTrialReviewVO trial = requirePendingTrial(trialNo);

        int updated = adminTrialReviewDAO.approveTrial(trial.getTrialNo());
        if (updated != 1) {
            throw new IllegalStateException("검수 상태가 변경되어 승인 처리할 수 없습니다. 화면을 새로고침해주세요.");
        }

        adminTrialReviewDAO.insertReviewLog(
                adminMemberNo,
                trialNo,
                "APPROVE",
                null);
    }

    @Override
    @Transactional
    public void rejectTrial(Long adminMemberNo, Long trialNo, String rejectReason) {
        validateAdminAndTrial(adminMemberNo, trialNo);
        String normalizedReason = trimToNull(rejectReason);
        if (normalizedReason == null) {
            throw new IllegalArgumentException("반려 사유를 입력해주세요.");
        }
        if (normalizedReason.length() > 1000) {
            throw new IllegalArgumentException("반려 사유는 1000자 이내로 입력해주세요.");
        }

        AdminTrialReviewVO trial = requirePendingTrial(trialNo);
        int updated = adminTrialReviewDAO.rejectTrial(trial.getTrialNo(), normalizedReason);
        if (updated != 1) {
            throw new IllegalStateException("검수 상태가 변경되어 반려 처리할 수 없습니다. 화면을 새로고침해주세요.");
        }

        adminTrialReviewDAO.insertReviewLog(
                adminMemberNo,
                trialNo,
                "REJECT",
                normalizedReason);
    }

    private AdminTrialReviewVO requirePendingTrial(Long trialNo) {
        AdminTrialReviewVO trial = adminTrialReviewDAO.selectReviewTrialByNo(trialNo);
        if (trial == null) {
            throw new IllegalArgumentException("검수할 사업자 임상시험을 찾을 수 없습니다.");
        }
        if (!PENDING.equals(trial.getReviewStatus())) {
            throw new IllegalStateException("검수대기 상태의 임상시험만 승인하거나 반려할 수 있습니다.");
        }
        return trial;
    }

    private void validateAdminAndTrial(Long adminMemberNo, Long trialNo) {
        if (adminMemberNo == null) {
            throw new IllegalStateException("관리자 로그인 정보를 확인할 수 없습니다.");
        }
        if (trialNo == null) {
            throw new IllegalArgumentException("임상시험 번호를 확인해주세요.");
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
