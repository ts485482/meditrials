package meditrials.meditrials.plan.dao;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import meditrials.meditrials.plan.vo.PlanPolicyVO;

@Mapper
public interface PlanPolicyDAO {

    PlanPolicyVO selectPlanPolicy(@Param("planType") String planType);

    int updatePremiumMonthlyFee(
            @Param("monthlyFee") Long monthlyFee,
            @Param("updatedBy") Long updatedBy);
}
