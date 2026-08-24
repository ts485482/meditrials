package meditrials.meditrials.admin.revenue.service;

import java.util.List;

import org.springframework.stereotype.Service;

import meditrials.meditrials.admin.revenue.dao.AdminRevenueDAO;
import meditrials.meditrials.admin.revenue.vo.AdminMonthlyRevenueVO;
import meditrials.meditrials.admin.revenue.vo.AdminRevenueSummaryVO;

@Service
public class AdminRevenueServiceImpl implements AdminRevenueService {

    private final AdminRevenueDAO adminRevenueDAO;

    public AdminRevenueServiceImpl(AdminRevenueDAO adminRevenueDAO) {
        this.adminRevenueDAO = adminRevenueDAO;
    }

    @Override
    public AdminRevenueSummaryVO getRevenueSummary() {
        AdminRevenueSummaryVO summary = adminRevenueDAO.selectRevenueSummary();
        return summary == null ? new AdminRevenueSummaryVO() : summary;
    }

    @Override
    public List<AdminMonthlyRevenueVO> getMonthlyRevenueList() {
        List<AdminMonthlyRevenueVO> monthlyRevenue = adminRevenueDAO.selectMonthlyRevenueList();
        return monthlyRevenue == null ? List.of() : monthlyRevenue;
    }
}
