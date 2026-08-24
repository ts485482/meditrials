package meditrials.meditrials.business.stats.service;

import java.util.List;

import org.springframework.stereotype.Service;

import meditrials.meditrials.business.service.BusinessService;
import meditrials.meditrials.business.stats.dao.BusinessStatsDAO;
import meditrials.meditrials.business.stats.vo.BusinessStatsDetailVO;
import meditrials.meditrials.business.stats.vo.BusinessStatsVO;
import meditrials.meditrials.business.vo.BusinessVO;

@Service
public class BusinessStatsServiceImpl implements BusinessStatsService {

    private final BusinessStatsDAO businessStatsDAO;
    private final BusinessService businessService;

    public BusinessStatsServiceImpl(
            BusinessStatsDAO businessStatsDAO,
            BusinessService businessService) {
        this.businessStatsDAO = businessStatsDAO;
        this.businessService = businessService;
    }

    @Override
    public BusinessStatsVO getBusinessStats(Long memberNo) {
        if (memberNo == null) {
            throw new IllegalArgumentException("LOGIN_REQUIRED");
        }

        BusinessVO business = businessService.getBusinessByMemberNo(memberNo);
        if (business == null || business.getBusinessNo() == null) {
            throw new IllegalStateException("BUSINESS_NOT_FOUND");
        }

        List<BusinessStatsDetailVO> trialStats =
                businessStatsDAO.selectTrialStatsByBusinessNo(business.getBusinessNo());
        List<BusinessStatsDetailVO> dailyStats =
                businessStatsDAO.selectDailyStatsByBusinessNo(business.getBusinessNo());

        BusinessStatsVO stats = new BusinessStatsVO();
        stats.setTrialStats(trialStats);
        stats.setDailyStats(dailyStats);

        long viewCount = sumViews(trialStats);
        long favoriteCount = sumFavorites(trialStats);
        long inquiryCount = sumInquiries(trialStats);
        long participantCount = sumParticipants(trialStats);

        stats.setViewCount(viewCount);
        stats.setFavoriteCount(favoriteCount);
        stats.setInquiryCount(inquiryCount);
        stats.setParticipantCount(participantCount);
        stats.setViewToFavoriteRate(rate(favoriteCount, viewCount));
        stats.setFavoriteToInquiryRate(rate(inquiryCount, favoriteCount));
        stats.setInquiryToParticipantRate(rate(participantCount, inquiryCount));
        return stats;
    }

    private long sumViews(List<BusinessStatsDetailVO> stats) {
        return stats == null ? 0L : stats.stream().mapToLong(BusinessStatsDetailVO::getViewCount).sum();
    }

    private long sumFavorites(List<BusinessStatsDetailVO> stats) {
        return stats == null ? 0L : stats.stream().mapToLong(BusinessStatsDetailVO::getFavoriteCount).sum();
    }

    private long sumInquiries(List<BusinessStatsDetailVO> stats) {
        return stats == null ? 0L : stats.stream().mapToLong(BusinessStatsDetailVO::getInquiryCount).sum();
    }

    private long sumParticipants(List<BusinessStatsDetailVO> stats) {
        return stats == null ? 0L : stats.stream().mapToLong(BusinessStatsDetailVO::getParticipantCount).sum();
    }

    private double rate(long numerator, long denominator) {
        if (denominator <= 0L) {
            return 0.0d;
        }
        return Math.round((numerator * 1000.0d) / denominator) / 10.0d;
    }
}
