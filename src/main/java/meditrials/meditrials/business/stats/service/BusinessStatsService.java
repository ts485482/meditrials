package meditrials.meditrials.business.stats.service;

import meditrials.meditrials.business.stats.vo.BusinessStatsVO;

public interface BusinessStatsService {

    BusinessStatsVO getBusinessStats(Long memberNo);
}
