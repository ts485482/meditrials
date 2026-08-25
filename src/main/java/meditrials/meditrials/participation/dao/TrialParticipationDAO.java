package meditrials.meditrials.participation.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import meditrials.meditrials.participation.vo.TrialParticipationVO;

@Mapper
public interface TrialParticipationDAO {

    int insertParticipation(TrialParticipationVO participation);

    TrialParticipationVO selectMemberTrialParticipation(
            @Param("memberNo") Long memberNo,
            @Param("trialNo") Long trialNo);

    TrialParticipationVO selectMemberParticipation(
            @Param("memberNo") Long memberNo,
            @Param("participationNo") Long participationNo);

    List<TrialParticipationVO> selectMemberParticipations(@Param("memberNo") Long memberNo);

    TrialParticipationVO selectBusinessParticipation(
            @Param("businessNo") Long businessNo,
            @Param("participationNo") Long participationNo);

    List<TrialParticipationVO> selectBusinessParticipations(@Param("businessNo") Long businessNo);

    int reapplyParticipation(
            @Param("participationNo") Long participationNo,
            @Param("memberNo") Long memberNo,
            @Param("businessNo") Long businessNo);

    int withdrawParticipation(
            @Param("participationNo") Long participationNo,
            @Param("memberNo") Long memberNo);

    int approveParticipation(
            @Param("participationNo") Long participationNo,
            @Param("businessNo") Long businessNo);

    int rejectParticipation(
            @Param("participationNo") Long participationNo,
            @Param("businessNo") Long businessNo);
}
