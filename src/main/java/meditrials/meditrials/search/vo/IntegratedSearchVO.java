package meditrials.meditrials.search.vo;

import java.util.ArrayList;
import java.util.List;

import meditrials.meditrials.disease.vo.DiseaseVO;
import meditrials.meditrials.trial.vo.TrialVO;

public class IntegratedSearchVO {

    private String keyword;
    private List<DiseaseVO> diseases = new ArrayList<>();
    private List<TrialVO> trials = new ArrayList<>();
    private int diseaseTotalCount;
    private int trialDisplayedCount;
    private boolean diseaseApiAvailable = true;
    private boolean trialApiAvailable = true;
    private String diseaseNotice;
    private String trialNotice;

    public String getKeyword() {
        return keyword;
    }

    public void setKeyword(String keyword) {
        this.keyword = keyword;
    }

    public List<DiseaseVO> getDiseases() {
        return diseases;
    }

    public void setDiseases(List<DiseaseVO> diseases) {
        this.diseases = diseases == null ? new ArrayList<>() : diseases;
    }

    public List<TrialVO> getTrials() {
        return trials;
    }

    public void setTrials(List<TrialVO> trials) {
        this.trials = trials == null ? new ArrayList<>() : trials;
    }

    public int getDiseaseTotalCount() {
        return diseaseTotalCount;
    }

    public void setDiseaseTotalCount(int diseaseTotalCount) {
        this.diseaseTotalCount = diseaseTotalCount;
    }

    public int getTrialDisplayedCount() {
        return trialDisplayedCount;
    }

    public void setTrialDisplayedCount(int trialDisplayedCount) {
        this.trialDisplayedCount = trialDisplayedCount;
    }

    public boolean isDiseaseApiAvailable() {
        return diseaseApiAvailable;
    }

    public void setDiseaseApiAvailable(boolean diseaseApiAvailable) {
        this.diseaseApiAvailable = diseaseApiAvailable;
    }

    public boolean isTrialApiAvailable() {
        return trialApiAvailable;
    }

    public void setTrialApiAvailable(boolean trialApiAvailable) {
        this.trialApiAvailable = trialApiAvailable;
    }

    public String getDiseaseNotice() {
        return diseaseNotice;
    }

    public void setDiseaseNotice(String diseaseNotice) {
        this.diseaseNotice = diseaseNotice;
    }

    public String getTrialNotice() {
        return trialNotice;
    }

    public void setTrialNotice(String trialNotice) {
        this.trialNotice = trialNotice;
    }

    public int getTotalPreviewCount() {
        return diseases.size() + trials.size();
    }
}
