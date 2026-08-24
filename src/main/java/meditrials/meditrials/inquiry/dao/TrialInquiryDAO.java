package meditrials.meditrials.inquiry.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import meditrials.meditrials.inquiry.vo.TrialInquiryVO;

@Mapper
public interface TrialInquiryDAO {

    int insertInquiry(TrialInquiryVO inquiry);

    List<TrialInquiryVO> selectMemberInquiries(@Param("memberNo") Long memberNo);

    TrialInquiryVO selectMemberInquiry(
            @Param("memberNo") Long memberNo,
            @Param("inquiryNo") Long inquiryNo);

    List<TrialInquiryVO> selectBusinessInquiries(@Param("businessNo") Long businessNo);

    TrialInquiryVO selectBusinessInquiry(
            @Param("businessNo") Long businessNo,
            @Param("inquiryNo") Long inquiryNo);

    int updateBusinessAnswer(
            @Param("businessNo") Long businessNo,
            @Param("inquiryNo") Long inquiryNo,
            @Param("answer") String answer);
}
