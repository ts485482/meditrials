package meditrials.meditrials.business.trial.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import meditrials.meditrials.business.trial.vo.BusinessTrialVO;

@Mapper
public interface BusinessTrialDAO {

    List<BusinessTrialVO> selectBusinessTrialList(@Param("businessNo") Long businessNo);

    BusinessTrialVO selectBusinessTrialByNo(
            @Param("trialNo") Long trialNo,
            @Param("businessNo") Long businessNo);

    int insertBusinessTrial(BusinessTrialVO trial);

    int updateBusinessTrial(BusinessTrialVO trial);

    int deleteTrialDisease(@Param("trialNo") Long trialNo);

    int insertTrialDisease(
            @Param("trialNo") Long trialNo,
            @Param("diseaseNo") Long diseaseNo);
}
