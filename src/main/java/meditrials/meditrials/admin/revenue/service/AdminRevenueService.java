package meditrials.meditrials.admin.revenue.service;

import java.util.List;

import meditrials.meditrials.admin.revenue.vo.AdminMonthlyRevenueVO;
import meditrials.meditrials.admin.revenue.vo.AdminRevenueSummaryVO;

public interface AdminRevenueService {

    AdminRevenueSummaryVO getRevenueSummary();

    List<AdminMonthlyRevenueVO> getMonthlyRevenueList();
}
