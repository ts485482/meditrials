package meditrials.meditrials.business.promotion.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import meditrials.meditrials.business.promotion.vo.BusinessPromotionVO;

@Mapper
public interface BusinessPromotionDAO {

    List<BusinessPromotionVO> selectPromotionTrialList(@Param("memberNo") Long memberNo);

    BusinessPromotionVO selectPromotionTrialByNo(
            @Param("memberNo") Long memberNo,
            @Param("trialNo") Long trialNo);

    int countOpenPromotionForTrial(
            @Param("memberNo") Long memberNo,
            @Param("trialNo") Long trialNo);

    Long selectActiveSubscriptionNo(@Param("memberNo") Long memberNo);

    int insertPromotion(BusinessPromotionVO promotion);

    int endInactivePromotionsByMemberNo(@Param("memberNo") Long memberNo);
}
