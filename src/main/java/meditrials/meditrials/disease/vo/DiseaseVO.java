package meditrials.meditrials.disease.vo;

import java.time.LocalDateTime;

public class DiseaseVO {

    private Long diseaseNo;
    private String sourceType;
    private String sourceCode;
    private String diseaseName;
    private String englishName;
    private String category;
    private String description;
    private String symptomText;
    private String sourceUrl;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Integer relatedTrialCount;

    public Long getDiseaseNo() {
        return diseaseNo;
    }

    public void setDiseaseNo(Long diseaseNo) {
        this.diseaseNo = diseaseNo;
    }

    public String getSourceType() {
        return sourceType;
    }

    public void setSourceType(String sourceType) {
        this.sourceType = sourceType;
    }

    public String getSourceCode() {
        return sourceCode;
    }

    public void setSourceCode(String sourceCode) {
        this.sourceCode = sourceCode;
    }

    public String getDiseaseName() {
        return diseaseName;
    }

    public void setDiseaseName(String diseaseName) {
        this.diseaseName = diseaseName;
    }

    public String getEnglishName() {
        return englishName;
    }

    public void setEnglishName(String englishName) {
        this.englishName = englishName;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getSymptomText() {
        return symptomText;
    }

    public void setSymptomText(String symptomText) {
        this.symptomText = symptomText;
    }

    public String getSourceUrl() {
        return sourceUrl;
    }

    public void setSourceUrl(String sourceUrl) {
        this.sourceUrl = sourceUrl;
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

    public Integer getRelatedTrialCount() {
        return relatedTrialCount;
    }

    public void setRelatedTrialCount(Integer relatedTrialCount) {
        this.relatedTrialCount = relatedTrialCount;
    }
}
