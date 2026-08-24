package meditrials.meditrials.admin.trial.service;

import java.util.List;

import meditrials.meditrials.admin.trial.vo.AdminTrialReviewVO;

public interface AdminTrialReviewService {

    List<AdminTrialReviewVO> getReviewTrials();

    AdminTrialReviewVO getReviewTrial(Long trialNo);

    void approveTrial(Long adminMemberNo, Long trialNo);

    void rejectTrial(Long adminMemberNo, Long trialNo, String rejectReason);
}
