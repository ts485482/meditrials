package meditrials.meditrials.admin.dashboard.vo;

public class AdminRecentReviewVO {

    private Long reviewLogNo;
    private String createdAtText;
    private String targetType;
    private Long targetNo;
    private String targetName;
    private String actionType;
    private String adminName;

    public Long getReviewLogNo() {
        return reviewLogNo;
    }

    public void setReviewLogNo(Long reviewLogNo) {
        this.reviewLogNo = reviewLogNo;
    }

    public String getCreatedAtText() {
        return createdAtText;
    }

    public void setCreatedAtText(String createdAtText) {
        this.createdAtText = createdAtText;
    }

    public String getTargetType() {
        return targetType;
    }

    public void setTargetType(String targetType) {
        this.targetType = targetType;
    }

    public Long getTargetNo() {
        return targetNo;
    }

    public void setTargetNo(Long targetNo) {
        this.targetNo = targetNo;
    }

    public String getTargetName() {
        return targetName;
    }

    public void setTargetName(String targetName) {
        this.targetName = targetName;
    }

    public String getActionType() {
        return actionType;
    }

    public void setActionType(String actionType) {
        this.actionType = actionType;
    }

    public String getAdminName() {
        return adminName;
    }

    public void setAdminName(String adminName) {
        this.adminName = adminName;
    }
}
