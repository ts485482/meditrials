package meditrials.meditrials.admin.dashboard.vo;

public class AdminDashboardVO {

    private long userCount;
    private long businessCount;
    private long trialCount;
    private long inquiryCount;
    private long premiumBusinessCount;
    private long monthRevenue;
    private long pendingBusinessCount;
    private long approvedBusinessMonthCount;
    private long pendingTrialCount;
    private long rejectedTrialMonthCount;

    public long getUserCount() {
        return userCount;
    }

    public void setUserCount(long userCount) {
        this.userCount = userCount;
    }

    public long getBusinessCount() {
        return businessCount;
    }

    public void setBusinessCount(long businessCount) {
        this.businessCount = businessCount;
    }

    public long getTrialCount() {
        return trialCount;
    }

    public void setTrialCount(long trialCount) {
        this.trialCount = trialCount;
    }

    public long getInquiryCount() {
        return inquiryCount;
    }

    public void setInquiryCount(long inquiryCount) {
        this.inquiryCount = inquiryCount;
    }

    public long getPremiumBusinessCount() {
        return premiumBusinessCount;
    }

    public void setPremiumBusinessCount(long premiumBusinessCount) {
        this.premiumBusinessCount = premiumBusinessCount;
    }

    public long getMonthRevenue() {
        return monthRevenue;
    }

    public void setMonthRevenue(long monthRevenue) {
        this.monthRevenue = monthRevenue;
    }

    public long getPendingBusinessCount() {
        return pendingBusinessCount;
    }

    public void setPendingBusinessCount(long pendingBusinessCount) {
        this.pendingBusinessCount = pendingBusinessCount;
    }

    public long getApprovedBusinessMonthCount() {
        return approvedBusinessMonthCount;
    }

    public void setApprovedBusinessMonthCount(long approvedBusinessMonthCount) {
        this.approvedBusinessMonthCount = approvedBusinessMonthCount;
    }

    public long getPendingTrialCount() {
        return pendingTrialCount;
    }

    public void setPendingTrialCount(long pendingTrialCount) {
        this.pendingTrialCount = pendingTrialCount;
    }

    public long getRejectedTrialMonthCount() {
        return rejectedTrialMonthCount;
    }

    public void setRejectedTrialMonthCount(long rejectedTrialMonthCount) {
        this.rejectedTrialMonthCount = rejectedTrialMonthCount;
    }
}
