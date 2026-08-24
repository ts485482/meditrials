package meditrials.meditrials.admin.dashboard.service;

import java.util.List;

import meditrials.meditrials.admin.dashboard.vo.AdminDashboardVO;
import meditrials.meditrials.admin.dashboard.vo.AdminRecentReviewVO;

public interface AdminDashboardService {

    AdminDashboardVO getDashboardSummary();

    List<AdminRecentReviewVO> getRecentReviews();
}
