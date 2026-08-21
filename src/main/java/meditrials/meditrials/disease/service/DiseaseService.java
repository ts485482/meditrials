package meditrials.meditrials.disease.service;

import meditrials.meditrials.disease.vo.DiseaseSearchResultVO;
import meditrials.meditrials.disease.vo.DiseaseVO;

public interface DiseaseService {

    DiseaseSearchResultVO searchDiseases(String keyword, String category);

    DiseaseVO getDiseaseDetail(Long diseaseNo);
}
