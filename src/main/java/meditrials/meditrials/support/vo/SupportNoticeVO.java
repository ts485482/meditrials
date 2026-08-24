package meditrials.meditrials.support.vo;

import java.time.LocalDateTime;

public class SupportNoticeVO {

    private Long noticeNo;
    private Long adminMemberNo;
    private String adminName;
    private String title;
    private String content;
    private String pinned;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Long getNoticeNo() {
        return noticeNo;
    }

    public void setNoticeNo(Long noticeNo) {
        this.noticeNo = noticeNo;
    }

    public Long getAdminMemberNo() {
        return adminMemberNo;
    }

    public void setAdminMemberNo(Long adminMemberNo) {
        this.adminMemberNo = adminMemberNo;
    }

    public String getAdminName() {
        return adminName;
    }

    public void setAdminName(String adminName) {
        this.adminName = adminName;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getPinned() {
        return pinned;
    }

    public void setPinned(String pinned) {
        this.pinned = pinned;
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

    public boolean isPinnedNotice() {
        return "Y".equalsIgnoreCase(pinned);
    }
}
