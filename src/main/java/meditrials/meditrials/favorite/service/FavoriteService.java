package meditrials.meditrials.favorite.service;

import java.util.List;

import meditrials.meditrials.disease.vo.DiseaseVO;
import meditrials.meditrials.trial.vo.TrialVO;

public interface FavoriteService {

    boolean isDiseaseFavorite(Long memberNo, Long diseaseNo);

    boolean toggleDiseaseFavorite(Long memberNo, Long diseaseNo);

    List<DiseaseVO> getFavoriteDiseases(Long memberNo);

    boolean isTrialFavorite(Long memberNo, Long trialNo);

    boolean toggleTrialFavorite(Long memberNo, Long trialNo);

    List<TrialVO> getFavoriteTrials(Long memberNo);
}
