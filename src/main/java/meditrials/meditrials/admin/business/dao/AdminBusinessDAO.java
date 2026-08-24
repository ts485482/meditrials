package meditrials.meditrials.admin.business.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import meditrials.meditrials.business.vo.BusinessVO;

@Mapper
public interface AdminBusinessDAO {

    List<BusinessVO> selectBusinessList();

    BusinessVO selectBusinessByNo(@Param("businessNo") Long businessNo);

    int approveBusiness(@Param("businessNo") Long businessNo);

    int rejectBusiness(
            @Param("businessNo") Long businessNo,
            @Param("rejectReason") String rejectReason);

    int insertReviewLog(
            @Param("adminMemberNo") Long adminMemberNo,
            @Param("businessNo") Long businessNo,
            @Param("actionType") String actionType,
            @Param("reason") String reason);
}
