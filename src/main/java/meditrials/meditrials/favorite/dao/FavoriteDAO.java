package meditrials.meditrials.favorite.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import meditrials.meditrials.disease.vo.DiseaseVO;
import meditrials.meditrials.trial.vo.TrialVO;

@Mapper
public interface FavoriteDAO {

    int countFavoriteDisease(
            @Param("memberNo") Long memberNo,
            @Param("diseaseNo") Long diseaseNo);

    int insertFavoriteDisease(
            @Param("memberNo") Long memberNo,
            @Param("diseaseNo") Long diseaseNo);

    int deleteFavoriteDisease(
            @Param("memberNo") Long memberNo,
            @Param("diseaseNo") Long diseaseNo);

    List<DiseaseVO> selectFavoriteDiseaseList(@Param("memberNo") Long memberNo);

    int countFavoriteTrial(
            @Param("memberNo") Long memberNo,
            @Param("trialNo") Long trialNo);

    int insertFavoriteTrial(
            @Param("memberNo") Long memberNo,
            @Param("trialNo") Long trialNo);

    int deleteFavoriteTrial(
            @Param("memberNo") Long memberNo,
            @Param("trialNo") Long trialNo);

    List<TrialVO> selectFavoriteTrialList(@Param("memberNo") Long memberNo);
}
