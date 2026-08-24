package meditrials.meditrials.plan.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import meditrials.meditrials.plan.dao.PlanPolicyDAO;
import meditrials.meditrials.plan.vo.PlanPolicyVO;

@Service
public class PlanPolicyServiceImpl implements PlanPolicyService {

    private static final String PLAN_FREE = "FREE";
    private static final String PLAN_PREMIUM = "PREMIUM";
    private static final long MAX_PREMIUM_MONTHLY_FEE = 10_000_000L;

    private final PlanPolicyDAO planPolicyDAO;

    public PlanPolicyServiceImpl(PlanPolicyDAO planPolicyDAO) {
        this.planPolicyDAO = planPolicyDAO;
    }

    @Override
    public PlanPolicyVO getFreePolicy() {
        return requirePolicy(PLAN_FREE);
    }

    @Override
    public PlanPolicyVO getPremiumPolicy() {
        return requirePolicy(PLAN_PREMIUM);
    }

    @Override
    public long getPremiumMonthlyFee() {
        PlanPolicyVO policy = getPremiumPolicy();
        return policy.getMonthlyFee() == null ? 0L : policy.getMonthlyFee();
    }

    @Override
    @Transactional
    public void updatePremiumMonthlyFee(Long monthlyFee, Long adminMemberNo) {
        if (adminMemberNo == null) {
            throw new IllegalStateException("ADMIN_LOGIN_REQUIRED");
        }
        if (monthlyFee == null || monthlyFee < 0L) {
            throw new IllegalArgumentException("월 이용료는 0원 이상이어야 합니다.");
        }
        if (monthlyFee > MAX_PREMIUM_MONTHLY_FEE) {
            throw new IllegalArgumentException("월 이용료는 10,000,000원 이하로 입력해주세요.");
        }

        int updatedRows = planPolicyDAO.updatePremiumMonthlyFee(monthlyFee, adminMemberNo);
        if (updatedRows != 1) {
            throw new IllegalStateException("PREMIUM_POLICY_UPDATE_FAILED");
        }
    }

    private PlanPolicyVO requirePolicy(String planType) {
        PlanPolicyVO policy = planPolicyDAO.selectPlanPolicy(planType);
        if (policy == null) {
            throw new IllegalStateException("PLAN_POLICY_NOT_FOUND:" + planType);
        }
        return policy;
    }
}
