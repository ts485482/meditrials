package meditrials.meditrials.admin.dashboard.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import meditrials.meditrials.admin.dashboard.vo.AdminDashboardVO;
import meditrials.meditrials.admin.dashboard.vo.AdminRecentReviewVO;

@Mapper
public interface AdminDashboardDAO {

    AdminDashboardVO selectDashboardSummary();

    List<AdminRecentReviewVO> selectRecentReviews();
}
