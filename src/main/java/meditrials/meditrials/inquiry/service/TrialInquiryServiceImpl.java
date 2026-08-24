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

        TrialInquiryVO inquiry = new TrialInquiryVO();
        inquiry.setMemberNo(memberNo);
        inquiry.setTrialNo(trialNo);
        inquiry.setBusinessNo(trial.getBusinessNo());
        inquiry.setSubject(normalizedSubject);
        inquiry.setQuestion(normalizedQuestion);
        inquiry.setStatus("WAITING");

        int inserted = trialInquiryDAO.insertInquiry(inquiry);
        if (inserted != 1 || inquiry.getInquiryNo() == null) {
            throw new IllegalStateException("참여 문의를 저장하지 못했습니다.");
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

    private String normalize(String value) {
        return value == null ? "" : value.trim();
    }
}
