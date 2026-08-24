package meditrials.meditrials.admin.promotion.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import meditrials.meditrials.admin.promotion.vo.AdminPromotionVO;

@Mapper
public interface AdminPromotionDAO {

    List<AdminPromotionVO> selectPromotionList();

    AdminPromotionVO selectPromotionByNo(@Param("promotionNo") Long promotionNo);

    int approvePromotion(@Param("promotionNo") Long promotionNo);

    int rejectPromotion(
            @Param("promotionNo") Long promotionNo,
            @Param("rejectReason") String rejectReason);

    int insertReviewLog(
            @Param("adminMemberNo") Long adminMemberNo,
            @Param("promotionNo") Long promotionNo,
            @Param("actionType") String actionType,
            @Param("reason") String reason);

    int endInactivePromotions();
}
