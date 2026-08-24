package meditrials.meditrials.inquiry.service;

import java.util.List;

import meditrials.meditrials.inquiry.vo.TrialInquiryVO;

public interface TrialInquiryService {

    Long createInquiry(Long memberNo, Long trialNo, String subject, String question);

    List<TrialInquiryVO> getMemberInquiries(Long memberNo);

    TrialInquiryVO getMemberInquiry(Long memberNo, Long inquiryNo);
}
