package meditrials.meditrials.business.stats.vo;

/**
 * 사업자 임상시험 통계 상세 행 VO.
 * 임상시험별 통계와 최근 7일 일자별 통계 조회에 공통 사용한다.
 */
public class BusinessStatsDetailVO {

    private Long trialNo;
    private String title;
    private String periodLabel;
    private long viewCount;
    private long favoriteCount;
    private long inquiryCount;
    private long participantCount;

    public Long getTrialNo() {
        return trialNo;
    }

    public void setTrialNo(Long trialNo) {
        this.trialNo = trialNo;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getPeriodLabel() {
        return periodLabel;
    }

    public void setPeriodLabel(String periodLabel) {
        this.periodLabel = periodLabel;
    }

    public long getViewCount() {
        return viewCount;
    }

    public void setViewCount(long viewCount) {
        this.viewCount = viewCount;
    }

    public long getFavoriteCount() {
        return favoriteCount;
    }

    public void setFavoriteCount(long favoriteCount) {
        this.favoriteCount = favoriteCount;
    }

    public long getInquiryCount() {
        return inquiryCount;
    }

    public void setInquiryCount(long inquiryCount) {
        this.inquiryCount = inquiryCount;
    }

    public long getParticipantCount() {
        return participantCount;
    }

    public void setParticipantCount(long participantCount) {
        this.participantCount = participantCount;
    }
}
