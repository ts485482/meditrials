package meditrials.meditrials.mypage.vo;

public class MypageSummaryVO {

    private int favoriteDiseaseCount;
    private int favoriteTrialCount;
    private int inquiryCount;
    private int answeredInquiryCount;

    public int getFavoriteDiseaseCount() {
        return favoriteDiseaseCount;
    }

    public void setFavoriteDiseaseCount(int favoriteDiseaseCount) {
        this.favoriteDiseaseCount = favoriteDiseaseCount;
    }

    public int getFavoriteTrialCount() {
        return favoriteTrialCount;
    }

    public void setFavoriteTrialCount(int favoriteTrialCount) {
        this.favoriteTrialCount = favoriteTrialCount;
    }

    public int getInquiryCount() {
        return inquiryCount;
    }

    public void setInquiryCount(int inquiryCount) {
        this.inquiryCount = inquiryCount;
    }

    public int getAnsweredInquiryCount() {
        return answeredInquiryCount;
    }

    public void setAnsweredInquiryCount(int answeredInquiryCount) {
        this.answeredInquiryCount = answeredInquiryCount;
    }
}
