package meditrials.meditrials.admin.trial.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import meditrials.meditrials.admin.trial.vo.AdminTrialReviewVO;

@Mapper
public interface AdminTrialReviewDAO {

    List<AdminTrialReviewVO> selectReviewTrialList();

    AdminTrialReviewVO selectReviewTrialByNo(@Param("trialNo") Long trialNo);

    int approveTrial(@Param("trialNo") Long trialNo);

    int rejectTrial(
            @Param("trialNo") Long trialNo,
            @Param("rejectReason") String rejectReason);

    int insertReviewLog(
            @Param("adminMemberNo") Long adminMemberNo,
            @Param("trialNo") Long trialNo,
            @Param("actionType") String actionType,
            @Param("reason") String reason);
}
