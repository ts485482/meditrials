package meditrials.meditrials.trial.service;

import meditrials.meditrials.trial.vo.TrialSearchResultVO;
import meditrials.meditrials.trial.vo.TrialVO;

public interface TrialService {

    TrialSearchResultVO searchTrials(
            String keyword,
            String recruitmentStatus,
            String phase,
            String scope);

    TrialVO getTrialDetail(Long trialNo);
}
