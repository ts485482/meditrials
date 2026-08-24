package meditrials.meditrials.admin.promotion.vo;

import java.time.LocalDateTime;

public class AdminPromotionVO {

    private Long promotionNo;
    private Long trialNo;
    private Long businessNo;
    private Long subscriptionNo;
    private String orgName;
    private String title;
    private String phase;
    private String recruitmentStatus;
    private String institutionName;
    private String promotionStatus;
    private String rejectReason;
    private String subscriptionStatus;
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private LocalDateTime subscriptionEndDate;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Long getPromotionNo() { return promotionNo; }
    public void setPromotionNo(Long promotionNo) { this.promotionNo = promotionNo; }
    public Long getTrialNo() { return trialNo; }
    public void setTrialNo(Long trialNo) { this.trialNo = trialNo; }
    public Long getBusinessNo() { return businessNo; }
    public void setBusinessNo(Long businessNo) { this.businessNo = businessNo; }
    public Long getSubscriptionNo() { return subscriptionNo; }
    public void setSubscriptionNo(Long subscriptionNo) { this.subscriptionNo = subscriptionNo; }
    public String getOrgName() { return orgName; }
    public void setOrgName(String orgName) { this.orgName = orgName; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getPhase() { return phase; }
    public void setPhase(String phase) { this.phase = phase; }
    public String getRecruitmentStatus() { return recruitmentStatus; }
    public void setRecruitmentStatus(String recruitmentStatus) { this.recruitmentStatus = recruitmentStatus; }
    public String getInstitutionName() { return institutionName; }
    public void setInstitutionName(String institutionName) { this.institutionName = institutionName; }
    public String getPromotionStatus() { return promotionStatus; }
    public void setPromotionStatus(String promotionStatus) { this.promotionStatus = promotionStatus; }
    public String getRejectReason() { return rejectReason; }
    public void setRejectReason(String rejectReason) { this.rejectReason = rejectReason; }
    public String getSubscriptionStatus() { return subscriptionStatus; }
    public void setSubscriptionStatus(String subscriptionStatus) { this.subscriptionStatus = subscriptionStatus; }
    public LocalDateTime getStartDate() { return startDate; }
    public void setStartDate(LocalDateTime startDate) { this.startDate = startDate; }
    public LocalDateTime getEndDate() { return endDate; }
    public void setEndDate(LocalDateTime endDate) { this.endDate = endDate; }
    public LocalDateTime getSubscriptionEndDate() { return subscriptionEndDate; }
    public void setSubscriptionEndDate(LocalDateTime subscriptionEndDate) { this.subscriptionEndDate = subscriptionEndDate; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
