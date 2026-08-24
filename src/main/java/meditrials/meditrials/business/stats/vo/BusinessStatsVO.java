package meditrials.meditrials.business.stats.vo;

import java.util.ArrayList;
import java.util.List;

/** 사업자 PREMIUM 통계 화면용 집계 VO. */
public class BusinessStatsVO {

    private long viewCount;
    private long favoriteCount;
    private long inquiryCount;
    private long participantCount;

    private double viewToFavoriteRate;
    private double favoriteToInquiryRate;
    private double inquiryToParticipantRate;

    private List<BusinessStatsDetailVO> trialStats = new ArrayList<>();
    private List<BusinessStatsDetailVO> dailyStats = new ArrayList<>();

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

    public double getViewToFavoriteRate() {
        return viewToFavoriteRate;
    }

    public void setViewToFavoriteRate(double viewToFavoriteRate) {
        this.viewToFavoriteRate = viewToFavoriteRate;
    }

    public double getFavoriteToInquiryRate() {
        return favoriteToInquiryRate;
    }

    public void setFavoriteToInquiryRate(double favoriteToInquiryRate) {
        this.favoriteToInquiryRate = favoriteToInquiryRate;
    }

    public double getInquiryToParticipantRate() {
        return inquiryToParticipantRate;
    }

    public void setInquiryToParticipantRate(double inquiryToParticipantRate) {
        this.inquiryToParticipantRate = inquiryToParticipantRate;
    }

    public List<BusinessStatsDetailVO> getTrialStats() {
        return trialStats;
    }

    public void setTrialStats(List<BusinessStatsDetailVO> trialStats) {
        this.trialStats = trialStats == null ? new ArrayList<>() : trialStats;
    }

    public List<BusinessStatsDetailVO> getDailyStats() {
        return dailyStats;
    }

    public void setDailyStats(List<BusinessStatsDetailVO> dailyStats) {
        this.dailyStats = dailyStats == null ? new ArrayList<>() : dailyStats;
    }
}
