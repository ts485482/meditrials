package meditrials.meditrials.trial.service;

import java.util.List;

import meditrials.meditrials.trial.vo.TrialSearchResultVO;
import meditrials.meditrials.trial.vo.TrialVO;

public interface TrialService {

    TrialSearchResultVO searchTrials(
            String keyword,
            String recruitmentStatus,
            String phase,
            String scope);

    TrialVO getTrialDetail(Long trialNo);

    List<TrialVO> getActivePremiumTrials(int limit);

    List<TrialVO> getTodayTrials(int limit);

    void recordTrialView(Long trialNo, Long memberNo);
}
