package meditrials.meditrials.favorite.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import meditrials.meditrials.disease.vo.DiseaseVO;
import meditrials.meditrials.favorite.dao.FavoriteDAO;
import meditrials.meditrials.trial.vo.TrialVO;

@Service
public class FavoriteServiceImpl implements FavoriteService {

    private final FavoriteDAO favoriteDAO;

    public FavoriteServiceImpl(FavoriteDAO favoriteDAO) {
        this.favoriteDAO = favoriteDAO;
    }

    @Override
    public boolean isDiseaseFavorite(Long memberNo, Long diseaseNo) {
        if (memberNo == null || diseaseNo == null) {
            return false;
        }
        return favoriteDAO.countFavoriteDisease(memberNo, diseaseNo) > 0;
    }

    @Override
    @Transactional
    public boolean toggleDiseaseFavorite(Long memberNo, Long diseaseNo) {
        if (memberNo == null || diseaseNo == null) {
            return false;
        }

        if (favoriteDAO.countFavoriteDisease(memberNo, diseaseNo) > 0) {
            favoriteDAO.deleteFavoriteDisease(memberNo, diseaseNo);
            return false;
        }

        favoriteDAO.insertFavoriteDisease(memberNo, diseaseNo);
        return true;
    }

    @Override
    public List<DiseaseVO> getFavoriteDiseases(Long memberNo) {
        if (memberNo == null) {
            return List.of();
        }
        return favoriteDAO.selectFavoriteDiseaseList(memberNo);
    }

    @Override
    public boolean isTrialFavorite(Long memberNo, Long trialNo) {
        if (memberNo == null || trialNo == null) {
            return false;
        }
        return favoriteDAO.countFavoriteTrial(memberNo, trialNo) > 0;
    }

    @Override
    @Transactional
    public boolean toggleTrialFavorite(Long memberNo, Long trialNo) {
        if (memberNo == null || trialNo == null) {
            return false;
        }

        if (favoriteDAO.countFavoriteTrial(memberNo, trialNo) > 0) {
            favoriteDAO.deleteFavoriteTrial(memberNo, trialNo);
            return false;
        }

        favoriteDAO.insertFavoriteTrial(memberNo, trialNo);
        return true;
    }

    @Override
    public List<TrialVO> getFavoriteTrials(Long memberNo) {
        if (memberNo == null) {
            return List.of();
        }
        return favoriteDAO.selectFavoriteTrialList(memberNo);
    }
}
