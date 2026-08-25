package meditrials.meditrials.participation.service;

import java.util.List;

import meditrials.meditrials.participation.vo.TrialParticipationVO;

public interface TrialParticipationService {

    TrialParticipationVO requestParticipation(Long memberNo, Long trialNo);

    TrialParticipationVO getMemberTrialParticipation(Long memberNo, Long trialNo);

    TrialParticipationVO getMemberParticipation(Long memberNo, Long participationNo);

    List<TrialParticipationVO> getMemberParticipations(Long memberNo);

    void withdrawParticipation(Long memberNo, Long participationNo);

    TrialParticipationVO getBusinessParticipation(Long businessNo, Long participationNo);

    List<TrialParticipationVO> getBusinessParticipations(Long businessNo);

    void approveParticipation(Long businessNo, Long participationNo);

    void rejectParticipation(Long businessNo, Long participationNo);
}
