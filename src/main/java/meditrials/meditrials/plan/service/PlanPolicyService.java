package meditrials.meditrials.plan.service;

import meditrials.meditrials.plan.vo.PlanPolicyVO;

public interface PlanPolicyService {

    PlanPolicyVO getFreePolicy();

    PlanPolicyVO getPremiumPolicy();

    long getPremiumMonthlyFee();

    void updatePremiumMonthlyFee(Long monthlyFee, Long adminMemberNo);
}
