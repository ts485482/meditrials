package meditrials.meditrials.participation.vo;

import java.time.LocalDateTime;

public class TrialParticipationVO {

    private Long participationNo;
    private Long memberNo;
    private Long trialNo;
    private Long businessNo;
    private String status;
    private LocalDateTime appliedAt;
    private LocalDateTime approvedAt;
    private LocalDateTime startedAt;
    private LocalDateTime completedAt;

    // 화면 표시용 조인 필드
    private String trialTitle;
    private String recruitmentStatus;
    private String institutionName;
    private String memberName;
    private String memberEmail;
    private String businessOrgName;

    public Long getParticipationNo() {
        return participationNo;
    }

    public void setParticipationNo(Long participationNo) {
        this.participationNo = participationNo;
    }

    public Long getMemberNo() {
        return memberNo;
    }

    public void setMemberNo(Long memberNo) {
        this.memberNo = memberNo;
    }

    public Long getTrialNo() {
        return trialNo;
    }

    public void setTrialNo(Long trialNo) {
        this.trialNo = trialNo;
    }

    public Long getBusinessNo() {
        return businessNo;
    }

    public void setBusinessNo(Long businessNo) {
        this.businessNo = businessNo;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getAppliedAt() {
        return appliedAt;
    }

    public void setAppliedAt(LocalDateTime appliedAt) {
        this.appliedAt = appliedAt;
    }

    public LocalDateTime getApprovedAt() {
        return approvedAt;
    }

    public void setApprovedAt(LocalDateTime approvedAt) {
        this.approvedAt = approvedAt;
    }

    public LocalDateTime getStartedAt() {
        return startedAt;
    }

    public void setStartedAt(LocalDateTime startedAt) {
        this.startedAt = startedAt;
    }

    public LocalDateTime getCompletedAt() {
        return completedAt;
    }

    public void setCompletedAt(LocalDateTime completedAt) {
        this.completedAt = completedAt;
    }

    public String getTrialTitle() {
        return trialTitle;
    }

    public void setTrialTitle(String trialTitle) {
        this.trialTitle = trialTitle;
    }

    public String getRecruitmentStatus() {
        return recruitmentStatus;
    }

    public void setRecruitmentStatus(String recruitmentStatus) {
        this.recruitmentStatus = recruitmentStatus;
    }

    public String getInstitutionName() {
        return institutionName;
    }

    public void setInstitutionName(String institutionName) {
        this.institutionName = institutionName;
    }

    public String getMemberName() {
        return memberName;
    }

    public void setMemberName(String memberName) {
        this.memberName = memberName;
    }

    public String getMemberEmail() {
        return memberEmail;
    }

    public void setMemberEmail(String memberEmail) {
        this.memberEmail = memberEmail;
    }

    public String getBusinessOrgName() {
        return businessOrgName;
    }

    public void setBusinessOrgName(String businessOrgName) {
        this.businessOrgName = businessOrgName;
    }
}
