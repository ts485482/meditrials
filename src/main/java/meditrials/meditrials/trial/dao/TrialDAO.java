package meditrials.meditrials.trial.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import meditrials.meditrials.trial.vo.TrialVO;

@Mapper
public interface TrialDAO {

    int mergeTrial(TrialVO trial);

    TrialVO selectTrialByNo(@Param("trialNo") Long trialNo);

    TrialVO selectTrialByNctId(@Param("nctId") String nctId);

    List<TrialVO> selectCachedTrialList(
            @Param("keyword") String keyword,
            @Param("recruitmentStatus") String recruitmentStatus,
            @Param("limit") int limit);
}
