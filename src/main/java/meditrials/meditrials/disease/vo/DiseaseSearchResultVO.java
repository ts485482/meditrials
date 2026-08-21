package meditrials.meditrials.disease.vo;

import java.util.ArrayList;
import java.util.List;

public class DiseaseSearchResultVO {

    private List<DiseaseVO> diseases = new ArrayList<>();
    private int totalCount;
    private boolean apiAvailable;
    private String notice;

    public List<DiseaseVO> getDiseases() {
        return diseases;
    }

    public void setDiseases(List<DiseaseVO> diseases) {
        this.diseases = diseases;
    }

    public int getTotalCount() {
        return totalCount;
    }

    public void setTotalCount(int totalCount) {
        this.totalCount = totalCount;
    }

    public boolean isApiAvailable() {
        return apiAvailable;
    }

    public void setApiAvailable(boolean apiAvailable) {
        this.apiAvailable = apiAvailable;
    }

    public String getNotice() {
        return notice;
    }

    public void setNotice(String notice) {
        this.notice = notice;
    }
}
