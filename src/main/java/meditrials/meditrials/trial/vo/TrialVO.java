package meditrials.meditrials.trial.vo;

import java.time.LocalDateTime;

public class TrialVO {

    private Long trialNo;
    private String nctId;
    private Long businessNo;
    private String sourceType;
    private String title;
    private String officialTitle;
    private String briefSummary;
    private String phase;
    private String studyType;
    private String recruitmentStatus;
    private String eligibilityText;
    private String sex;
    private String minAge;
    private String maxAge;
    private Integer enrollmentTarget;
    private Integer enrollmentCurrent;
    private String leadSponsor;
    private String institutionName;
    private String locationText;
    private String contactName;
    private String contactPhone;
    private String contactEmail;
    private String startDateText;
    private String completionDateText;
    private String reviewStatus;
    private String rejectReason;
    private Integer viewCount;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // API 화면 표시용 비영속 필드
    private String conditionsText;
    private Integer locationCount;
    private boolean premiumPromoted;

    public Long getTrialNo() {
        return trialNo;
    }

    public void setTrialNo(Long trialNo) {
        this.trialNo = trialNo;
    }

    public String getNctId() {
        return nctId;
    }

    public void setNctId(String nctId) {
        this.nctId = nctId;
    }

    public Long getBusinessNo() {
        return businessNo;
    }

    public void setBusinessNo(Long businessNo) {
        this.businessNo = businessNo;
    }

    public String getSourceType() {
        return sourceType;
    }

    public void setSourceType(String sourceType) {
        this.sourceType = sourceType;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getOfficialTitle() {
        return officialTitle;
    }

    public void setOfficialTitle(String officialTitle) {
        this.officialTitle = officialTitle;
    }

    public String getBriefSummary() {
        return briefSummary;
    }

    public void setBriefSummary(String briefSummary) {
        this.briefSummary = briefSummary;
    }

    public String getPhase() {
        return phase;
    }

    public void setPhase(String phase) {
        this.phase = phase;
    }

    public String getStudyType() {
        return studyType;
    }

    public void setStudyType(String studyType) {
        this.studyType = studyType;
    }

    public String getRecruitmentStatus() {
        return recruitmentStatus;
    }

    public void setRecruitmentStatus(String recruitmentStatus) {
        this.recruitmentStatus = recruitmentStatus;
    }

    public String getEligibilityText() {
        return eligibilityText;
    }

    public void setEligibilityText(String eligibilityText) {
        this.eligibilityText = eligibilityText;
    }

    public String getSex() {
        return sex;
    }

    public void setSex(String sex) {
        this.sex = sex;
    }

    public String getMinAge() {
        return minAge;
    }

    public void setMinAge(String minAge) {
        this.minAge = minAge;
    }

    public String getMaxAge() {
        return maxAge;
    }

    public void setMaxAge(String maxAge) {
        this.maxAge = maxAge;
    }

    public Integer getEnrollmentTarget() {
        return enrollmentTarget;
    }

    public void setEnrollmentTarget(Integer enrollmentTarget) {
        this.enrollmentTarget = enrollmentTarget;
    }

    public Integer getEnrollmentCurrent() {
        return enrollmentCurrent;
    }

    public void setEnrollmentCurrent(Integer enrollmentCurrent) {
        this.enrollmentCurrent = enrollmentCurrent;
    }

    public String getLeadSponsor() {
        return leadSponsor;
    }

    public void setLeadSponsor(String leadSponsor) {
        this.leadSponsor = leadSponsor;
    }

    public String getInstitutionName() {
        return institutionName;
    }

    public void setInstitutionName(String institutionName) {
        this.institutionName = institutionName;
    }

    public String getLocationText() {
        return locationText;
    }

    public void setLocationText(String locationText) {
        this.locationText = locationText;
    }

    public String getContactName() {
        return contactName;
    }

    public void setContactName(String contactName) {
        this.contactName = contactName;
    }

    public String getContactPhone() {
        return contactPhone;
    }

    public void setContactPhone(String contactPhone) {
        this.contactPhone = contactPhone;
    }

    public String getContactEmail() {
        return contactEmail;
    }

    public void setContactEmail(String contactEmail) {
        this.contactEmail = contactEmail;
    }

    public String getStartDateText() {
        return startDateText;
    }

    public void setStartDateText(String startDateText) {
        this.startDateText = startDateText;
    }

    public String getCompletionDateText() {
        return completionDateText;
    }

    public void setCompletionDateText(String completionDateText) {
        this.completionDateText = completionDateText;
    }

    public String getReviewStatus() {
        return reviewStatus;
    }

    public void setReviewStatus(String reviewStatus) {
        this.reviewStatus = reviewStatus;
    }

    public String getRejectReason() {
        return rejectReason;
    }

    public void setRejectReason(String rejectReason) {
        this.rejectReason = rejectReason;
    }

    public Integer getViewCount() {
        return viewCount;
    }

    public void setViewCount(Integer viewCount) {
        this.viewCount = viewCount;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getConditionsText() {
        return conditionsText;
    }

    public void setConditionsText(String conditionsText) {
        this.conditionsText = conditionsText;
    }

    public Integer getLocationCount() {
        return locationCount;
    }

    public void setLocationCount(Integer locationCount) {
        this.locationCount = locationCount;
    }

    public boolean isPremiumPromoted() {
        return premiumPromoted;
    }

    public void setPremiumPromoted(boolean premiumPromoted) {
        this.premiumPromoted = premiumPromoted;
    }
}

