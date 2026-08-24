package meditrials.meditrials.mypage.vo;

import java.time.LocalDateTime;

public class MypageRecentItemVO {

    private Long targetNo;
    private String title;
    private String subtitle;
    private String status;
    private LocalDateTime createdAt;

    public Long getTargetNo() {
        return targetNo;
    }

    public void setTargetNo(Long targetNo) {
        this.targetNo = targetNo;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getSubtitle() {
        return subtitle;
    }

    public void setSubtitle(String subtitle) {
        this.subtitle = subtitle;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
