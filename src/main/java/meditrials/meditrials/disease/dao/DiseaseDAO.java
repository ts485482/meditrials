package meditrials.meditrials.disease.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import meditrials.meditrials.disease.vo.DiseaseVO;

@Mapper
public interface DiseaseDAO {

    int mergeDisease(DiseaseVO disease);

    int updateDiseaseDetail(DiseaseVO disease);

    DiseaseVO selectDiseaseByNo(@Param("diseaseNo") Long diseaseNo);

    DiseaseVO selectDiseaseBySourceCode(@Param("sourceCode") String sourceCode);

    List<DiseaseVO> selectDiseaseList(
            @Param("keyword") String keyword,
            @Param("category") String category,
            @Param("limit") int limit);

    int countDiseaseList(
            @Param("keyword") String keyword,
            @Param("category") String category);

    int countDiseaseBySourceType(@Param("sourceType") String sourceType);
}
