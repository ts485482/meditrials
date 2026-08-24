package meditrials.meditrials.trial.vo;

import java.util.ArrayList;
import java.util.List;

public class TrialSearchResultVO {

    private List<TrialVO> trials = new ArrayList<>();
    private int displayedCount;
    private Integer apiTotalCount;
    private Integer crisTotalCount;
    private Integer clinicalTrialsTotalCount;
    private boolean apiAvailable = true;
    private boolean crisAvailable = true;
    private String notice;

    public List<TrialVO> getTrials() {
        return trials;
    }

    public void setTrials(List<TrialVO> trials) {
        this.trials = trials == null ? new ArrayList<>() : trials;
    }

    public int getDisplayedCount() {
        return displayedCount;
    }

    public void setDisplayedCount(int displayedCount) {
        this.displayedCount = displayedCount;
    }

    public Integer getApiTotalCount() {
        return apiTotalCount;
    }

    public void setApiTotalCount(Integer apiTotalCount) {
        this.apiTotalCount = apiTotalCount;
    }

    public Integer getCrisTotalCount() {
        return crisTotalCount;
    }

    public void setCrisTotalCount(Integer crisTotalCount) {
        this.crisTotalCount = crisTotalCount;
    }

    public Integer getClinicalTrialsTotalCount() {
        return clinicalTrialsTotalCount;
    }

    public void setClinicalTrialsTotalCount(Integer clinicalTrialsTotalCount) {
        this.clinicalTrialsTotalCount = clinicalTrialsTotalCount;
    }

    public boolean isApiAvailable() {
        return apiAvailable;
    }

    public void setApiAvailable(boolean apiAvailable) {
        this.apiAvailable = apiAvailable;
    }

    public boolean isCrisAvailable() {
        return crisAvailable;
    }

    public void setCrisAvailable(boolean crisAvailable) {
        this.crisAvailable = crisAvailable;
    }

    public String getNotice() {
        return notice;
    }

    public void setNotice(String notice) {
        this.notice = notice;
    }
}
