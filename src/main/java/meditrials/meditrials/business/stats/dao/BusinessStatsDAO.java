package meditrials.meditrials.business.stats.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import meditrials.meditrials.business.stats.vo.BusinessStatsDetailVO;

@Mapper
public interface BusinessStatsDAO {

    List<BusinessStatsDetailVO> selectTrialStatsByBusinessNo(
            @Param("businessNo") Long businessNo);

    List<BusinessStatsDetailVO> selectDailyStatsByBusinessNo(
            @Param("businessNo") Long businessNo);
}
