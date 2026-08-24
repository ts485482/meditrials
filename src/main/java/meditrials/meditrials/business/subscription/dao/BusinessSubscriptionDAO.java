package meditrials.meditrials.business.subscription.dao;

import java.time.LocalDateTime;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import meditrials.meditrials.business.subscription.vo.BusinessSubscriptionVO;

@Mapper
public interface BusinessSubscriptionDAO {

    BusinessSubscriptionVO selectLatestPremiumByMemberNo(@Param("memberNo") Long memberNo);

    int countOpenPremiumByMemberNo(@Param("memberNo") Long memberNo);

    int insertPremiumSubscription(BusinessSubscriptionVO subscription);

    int insertPendingPayment(BusinessSubscriptionVO subscription);

    int schedulePremiumCancellation(
            @Param("subscriptionNo") Long subscriptionNo,
            @Param("endDate") LocalDateTime endDate);

    int resumePremiumAutoBilling(@Param("subscriptionNo") Long subscriptionNo);

    List<BusinessSubscriptionVO> selectActivePremiumForAutoBilling();

    int insertAutoPaidPayment(BusinessSubscriptionVO subscription);

    int closeExpiredPremiumSubscriptions();
}
