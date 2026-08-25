package meditrials.meditrials.trial.service;

import java.util.List;

import meditrials.meditrials.trial.vo.TrialSearchResultVO;
import meditrials.meditrials.trial.vo.TrialVO;

public interface TrialService {

    default TrialSearchResultVO searchTrials(
            String keyword,
            String recruitmentStatus,
            String phase,
            String scope) {
        return searchTrials(keyword, recruitmentStatus, phase, scope, "RECOMMENDED");
    }

    TrialSearchResultVO searchTrials(
            String keyword,
            String recruitmentStatus,
            String phase,
            String scope,
            String sort);

    TrialVO getTrialDetail(Long trialNo);

    List<TrialVO> getActivePremiumTrials(int limit);

    List<TrialVO> getTodayTrials(int limit);

    void recordTrialView(Long trialNo, Long memberNo);
}
