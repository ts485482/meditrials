package meditrials.meditrials.business.trial.service;

import java.util.List;

import meditrials.meditrials.business.trial.vo.BusinessTrialVO;
import meditrials.meditrials.disease.vo.DiseaseVO;

public interface BusinessTrialService {

    List<BusinessTrialVO> getBusinessTrials(Long memberNo);

    BusinessTrialVO getBusinessTrial(Long memberNo, Long trialNo);

    List<DiseaseVO> getDiseaseOptions();

    boolean canManageTrials(Long memberNo);

    Long saveBusinessTrial(Long memberNo, BusinessTrialVO trial, String action);
}
