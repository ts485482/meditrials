package meditrials.meditrials.participation.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import meditrials.meditrials.participation.dao.TrialParticipationDAO;
import meditrials.meditrials.participation.vo.TrialParticipationVO;
import meditrials.meditrials.trial.dao.TrialDAO;
import meditrials.meditrials.trial.vo.TrialVO;

@Service
public class TrialParticipationServiceImpl implements TrialParticipationService {

    private final TrialParticipationDAO trialParticipationDAO;
    private final TrialDAO trialDAO;

    public TrialParticipationServiceImpl(
            TrialParticipationDAO trialParticipationDAO,
            TrialDAO trialDAO) {
        this.trialParticipationDAO = trialParticipationDAO;
        this.trialDAO = trialDAO;
    }

    @Override
    @Transactional
    public TrialParticipationVO requestParticipation(Long memberNo, Long trialNo) {
        if (memberNo == null) {
            throw new IllegalArgumentException("로그인 정보를 확인할 수 없습니다.");
        }
        if (trialNo == null) {
            throw new IllegalArgumentException("참여 요청할 임상시험을 확인할 수 없습니다.");
        }

        TrialVO trial = trialDAO.selectTrialByNo(trialNo);
        validateParticipationTrial(trial);

        TrialParticipationVO existing = trialParticipationDAO.selectMemberTrialParticipation(memberNo, trialNo);
        if (existing != null) {
            if ("REJECTED".equals(existing.getStatus()) || "WITHDRAWN".equals(existing.getStatus())) {
                int updated = trialParticipationDAO.reapplyParticipation(
                        existing.getParticipationNo(),
                        memberNo,
                        trial.getBusinessNo());
                if (updated != 1) {
                    throw new IllegalStateException("참여 요청을 다시 등록하지 못했습니다.");
                }
                return trialParticipationDAO.selectMemberTrialParticipation(memberNo, trialNo);
            }

            if ("APPLIED".equals(existing.getStatus())) {
                throw new IllegalArgumentException("이미 참여 요청이 접수되어 사업자 검토를 기다리고 있습니다.");
            }
            if ("APPROVED".equals(existing.getStatus())) {
                throw new IllegalArgumentException("이미 참여 요청이 승인된 임상시험입니다.");
            }
            if ("PARTICIPATING".equals(existing.getStatus())) {
                throw new IllegalArgumentException("현재 참여 중인 임상시험입니다.");
            }
            if ("COMPLETED".equals(existing.getStatus())) {
                throw new IllegalArgumentException("이미 참여가 완료된 임상시험입니다.");
            }
        }

        TrialParticipationVO participation = new TrialParticipationVO();
        participation.setMemberNo(memberNo);
        participation.setTrialNo(trialNo);
        participation.setBusinessNo(trial.getBusinessNo());
        participation.setStatus("APPLIED");

        int inserted = trialParticipationDAO.insertParticipation(participation);
        if (inserted != 1 || participation.getParticipationNo() == null) {
            throw new IllegalStateException("참여 요청을 저장하지 못했습니다.");
        }
        return trialParticipationDAO.selectMemberTrialParticipation(memberNo, trialNo);
    }

    @Override
    public TrialParticipationVO getMemberTrialParticipation(Long memberNo, Long trialNo) {
        if (memberNo == null || trialNo == null) {
            return null;
        }
        return trialParticipationDAO.selectMemberTrialParticipation(memberNo, trialNo);
    }

    @Override
    public TrialParticipationVO getMemberParticipation(Long memberNo, Long participationNo) {
        if (memberNo == null || participationNo == null) {
            return null;
        }
        return trialParticipationDAO.selectMemberParticipation(memberNo, participationNo);
    }

    @Override
    public List<TrialParticipationVO> getMemberParticipations(Long memberNo) {
        if (memberNo == null) {
            return List.of();
        }
        return trialParticipationDAO.selectMemberParticipations(memberNo);
    }

    @Override
    @Transactional
    public void withdrawParticipation(Long memberNo, Long participationNo) {
        if (memberNo == null || participationNo == null) {
            throw new IllegalArgumentException("취소할 참여 요청을 확인할 수 없습니다.");
        }

        TrialParticipationVO participation = trialParticipationDAO.selectMemberParticipation(memberNo, participationNo);
        if (participation == null) {
            throw new IllegalArgumentException("참여 요청 내역을 찾을 수 없습니다.");
        }
        if (!"APPLIED".equals(participation.getStatus())) {
            throw new IllegalArgumentException("검토 중인 참여 요청만 취소할 수 있습니다.");
        }

        int updated = trialParticipationDAO.withdrawParticipation(participationNo, memberNo);
        if (updated != 1) {
            throw new IllegalStateException("참여 요청을 취소하지 못했습니다.");
        }
    }

    @Override
    public TrialParticipationVO getBusinessParticipation(Long businessNo, Long participationNo) {
        if (businessNo == null || participationNo == null) {
            return null;
        }
        return trialParticipationDAO.selectBusinessParticipation(businessNo, participationNo);
    }

    @Override
    public List<TrialParticipationVO> getBusinessParticipations(Long businessNo) {
        if (businessNo == null) {
            return List.of();
        }
        return trialParticipationDAO.selectBusinessParticipations(businessNo);
    }

    @Override
    @Transactional
    public void approveParticipation(Long businessNo, Long participationNo) {
        TrialParticipationVO participation = requireBusinessAppliedParticipation(businessNo, participationNo);
        int updated = trialParticipationDAO.approveParticipation(
                participation.getParticipationNo(), businessNo);
        if (updated != 1) {
            throw new IllegalStateException("참여 요청을 승인하지 못했습니다.");
        }
    }

    @Override
    @Transactional
    public void rejectParticipation(Long businessNo, Long participationNo) {
        TrialParticipationVO participation = requireBusinessAppliedParticipation(businessNo, participationNo);
        int updated = trialParticipationDAO.rejectParticipation(
                participation.getParticipationNo(), businessNo);
        if (updated != 1) {
            throw new IllegalStateException("참여 요청을 거절하지 못했습니다.");
        }
    }

    @Override
    @Transactional
    public void startParticipation(Long businessNo, Long participationNo) {
        TrialParticipationVO participation = requireBusinessParticipationStatus(
                businessNo,
                participationNo,
                "APPROVED",
                "참여 승인 상태에서만 참여 시작으로 변경할 수 있습니다.");
        int updated = trialParticipationDAO.startParticipation(
                participation.getParticipationNo(), businessNo);
        if (updated != 1) {
            throw new IllegalStateException("참여 시작 상태로 변경하지 못했습니다.");
        }
    }

    @Override
    @Transactional
    public void completeParticipation(Long businessNo, Long participationNo) {
        TrialParticipationVO participation = requireBusinessParticipationStatus(
                businessNo,
                participationNo,
                "PARTICIPATING",
                "참여 중인 내역만 참여 완료로 변경할 수 있습니다.");
        int updated = trialParticipationDAO.completeParticipation(
                participation.getParticipationNo(), businessNo);
        if (updated != 1) {
            throw new IllegalStateException("참여 완료 상태로 변경하지 못했습니다.");
        }
    }

    private TrialParticipationVO requireBusinessAppliedParticipation(Long businessNo, Long participationNo) {
        if (businessNo == null) {
            throw new IllegalArgumentException("사업자 정보를 확인할 수 없습니다.");
        }
        if (participationNo == null) {
            throw new IllegalArgumentException("처리할 참여 요청을 확인할 수 없습니다.");
        }

        TrialParticipationVO participation = trialParticipationDAO.selectBusinessParticipation(
                businessNo, participationNo);
        if (participation == null) {
            throw new IllegalArgumentException("해당 사업자의 참여 요청을 찾을 수 없습니다.");
        }
        if (!"APPLIED".equals(participation.getStatus())) {
            throw new IllegalArgumentException("검토 대기 상태의 참여 요청만 승인 또는 거절할 수 있습니다.");
        }
        return participation;
    }

    private TrialParticipationVO requireBusinessParticipationStatus(
            Long businessNo,
            Long participationNo,
            String expectedStatus,
            String invalidStatusMessage) {
        if (businessNo == null) {
            throw new IllegalArgumentException("사업자 정보를 확인할 수 없습니다.");
        }
        if (participationNo == null) {
            throw new IllegalArgumentException("처리할 참여 내역을 확인할 수 없습니다.");
        }

        TrialParticipationVO participation = trialParticipationDAO.selectBusinessParticipation(
                businessNo, participationNo);
        if (participation == null) {
            throw new IllegalArgumentException("해당 사업자의 참여 내역을 찾을 수 없습니다.");
        }
        if (!expectedStatus.equals(participation.getStatus())) {
            throw new IllegalArgumentException(invalidStatusMessage);
        }
        return participation;
    }

    private void validateParticipationTrial(TrialVO trial) {
        if (trial == null) {
            throw new IllegalArgumentException("참여 요청할 임상시험을 찾을 수 없습니다.");
        }
        if (!"BUSINESS".equalsIgnoreCase(trial.getSourceType())
                || !"APPROVED".equalsIgnoreCase(trial.getReviewStatus())
                || trial.getBusinessNo() == null) {
            throw new IllegalArgumentException("MediTrials에서 승인된 사업자 임상시험에만 참여 요청할 수 있습니다.");
        }
        if (!"RECRUITING".equalsIgnoreCase(trial.getRecruitmentStatus())) {
            throw new IllegalArgumentException("현재 모집 중인 임상시험에만 참여 요청할 수 있습니다.");
        }
    }
}
