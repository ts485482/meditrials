package meditrials.meditrials.inquiry.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import meditrials.meditrials.inquiry.dao.TrialInquiryDAO;
import meditrials.meditrials.inquiry.vo.TrialInquiryVO;
import meditrials.meditrials.trial.dao.TrialDAO;
import meditrials.meditrials.trial.vo.TrialVO;

@Service
public class TrialInquiryServiceImpl implements TrialInquiryService {

    private static final int SUBJECT_MAX_LENGTH = 200;

    private final TrialInquiryDAO trialInquiryDAO;
    private final TrialDAO trialDAO;

    public TrialInquiryServiceImpl(
            TrialInquiryDAO trialInquiryDAO,
            TrialDAO trialDAO) {
        this.trialInquiryDAO = trialInquiryDAO;
        this.trialDAO = trialDAO;
    }

    @Override
    @Transactional
    public Long createInquiry(Long memberNo, Long trialNo, String subject, String question) {
        if (memberNo == null) {
            throw new IllegalArgumentException("로그인 정보가 확인되지 않습니다.");
        }
        if (trialNo == null) {
            throw new IllegalArgumentException("문의 대상 임상시험을 확인할 수 없습니다.");
        }

        String normalizedSubject = normalize(subject);
        String normalizedQuestion = normalize(question);

        if (normalizedSubject.isEmpty()) {
            throw new IllegalArgumentException("문의 제목을 입력해주세요.");
        }
        if (normalizedSubject.length() > SUBJECT_MAX_LENGTH) {
            throw new IllegalArgumentException("문의 제목은 200자 이내로 입력해주세요.");
        }
        if (normalizedQuestion.isEmpty()) {
            throw new IllegalArgumentException("문의 내용을 입력해주세요.");
        }

        TrialVO trial = trialDAO.selectTrialByNo(trialNo);
        if (trial == null) {
            throw new IllegalArgumentException("문의 대상 임상시험을 찾을 수 없습니다.");
        }
        if (!"BUSINESS".equalsIgnoreCase(trial.getSourceType())
                || !"APPROVED".equalsIgnoreCase(trial.getReviewStatus())
                || trial.getBusinessNo() == null) {
            throw new IllegalArgumentException("MediTrials에서 승인된 사업자 임상시험에만 문의를 등록할 수 있습니다.");
        }

        TrialInquiryVO inquiry = new TrialInquiryVO();
        inquiry.setMemberNo(memberNo);
        inquiry.setTrialNo(trialNo);
        inquiry.setBusinessNo(trial.getBusinessNo());
        inquiry.setSubject(normalizedSubject);
        inquiry.setQuestion(normalizedQuestion);
        inquiry.setStatus("WAITING");

        int inserted = trialInquiryDAO.insertInquiry(inquiry);
        if (inserted != 1 || inquiry.getInquiryNo() == null) {
            throw new IllegalStateException("문의를 저장하지 못했습니다.");
        }
        return inquiry.getInquiryNo();
    }

    @Override
    public List<TrialInquiryVO> getMemberInquiries(Long memberNo) {
        if (memberNo == null) {
            return List.of();
        }
        return trialInquiryDAO.selectMemberInquiries(memberNo);
    }

    @Override
    public TrialInquiryVO getMemberInquiry(Long memberNo, Long inquiryNo) {
        if (memberNo == null || inquiryNo == null) {
            return null;
        }
        return trialInquiryDAO.selectMemberInquiry(memberNo, inquiryNo);
    }

    @Override
    public List<TrialInquiryVO> getBusinessInquiries(Long businessNo) {
        if (businessNo == null) {
            return List.of();
        }
        return trialInquiryDAO.selectBusinessInquiries(businessNo);
    }

    @Override
    public TrialInquiryVO getBusinessInquiry(Long businessNo, Long inquiryNo) {
        if (businessNo == null || inquiryNo == null) {
            return null;
        }
        return trialInquiryDAO.selectBusinessInquiry(businessNo, inquiryNo);
    }

    @Override
    @Transactional
    public void answerBusinessInquiry(Long businessNo, Long inquiryNo, String answer) {
        if (businessNo == null) {
            throw new IllegalArgumentException("사업자 정보를 확인할 수 없습니다.");
        }
        if (inquiryNo == null) {
            throw new IllegalArgumentException("답변할 문의를 확인할 수 없습니다.");
        }

        String normalizedAnswer = normalize(answer);
        if (normalizedAnswer.isEmpty()) {
            throw new IllegalArgumentException("답변 내용을 입력해주세요.");
        }

        TrialInquiryVO inquiry = trialInquiryDAO.selectBusinessInquiry(businessNo, inquiryNo);
        if (inquiry == null) {
            throw new IllegalArgumentException("해당 사업자의 문의를 찾을 수 없습니다.");
        }
        if ("CLOSED".equals(inquiry.getStatus())) {
            throw new IllegalArgumentException("종료된 문의에는 답변을 등록할 수 없습니다.");
        }

        int updated = trialInquiryDAO.updateBusinessAnswer(businessNo, inquiryNo, normalizedAnswer);
        if (updated != 1) {
            throw new IllegalStateException("문의 답변을 저장하지 못했습니다.");
        }
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim();
    }
}
