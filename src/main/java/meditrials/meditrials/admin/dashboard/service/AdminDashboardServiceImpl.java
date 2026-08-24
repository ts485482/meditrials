package meditrials.meditrials.admin.dashboard.service;

import java.util.List;

import org.springframework.stereotype.Service;

import meditrials.meditrials.admin.dashboard.dao.AdminDashboardDAO;
import meditrials.meditrials.admin.dashboard.vo.AdminDashboardVO;
import meditrials.meditrials.admin.dashboard.vo.AdminRecentReviewVO;

@Service
public class AdminDashboardServiceImpl implements AdminDashboardService {

    private final AdminDashboardDAO adminDashboardDAO;

    public AdminDashboardServiceImpl(AdminDashboardDAO adminDashboardDAO) {
        this.adminDashboardDAO = adminDashboardDAO;
    }

    @Override
    public AdminDashboardVO getDashboardSummary() {
        AdminDashboardVO summary = adminDashboardDAO.selectDashboardSummary();
        return summary == null ? new AdminDashboardVO() : summary;
    }

    @Override
    public List<AdminRecentReviewVO> getRecentReviews() {
        List<AdminRecentReviewVO> reviews = adminDashboardDAO.selectRecentReviews();
        return reviews == null ? List.of() : reviews;
    }
}
