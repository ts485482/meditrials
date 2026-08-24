package meditrials.meditrials.business.subscription.dao;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import meditrials.meditrials.business.subscription.vo.BusinessSubscriptionVO;

@Mapper
public interface BusinessSubscriptionDAO {

    BusinessSubscriptionVO selectLatestPremiumByMemberNo(@Param("memberNo") Long memberNo);

    int countOpenPremiumByMemberNo(@Param("memberNo") Long memberNo);

    int insertPremiumSubscription(BusinessSubscriptionVO subscription);

    int insertPendingPayment(BusinessSubscriptionVO subscription);
}
