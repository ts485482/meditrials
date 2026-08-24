package meditrials.meditrials.admin.revenue.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import meditrials.meditrials.admin.revenue.vo.AdminMonthlyRevenueVO;
import meditrials.meditrials.admin.revenue.vo.AdminRevenueSummaryVO;

@Mapper
public interface AdminRevenueDAO {

    AdminRevenueSummaryVO selectRevenueSummary();

    List<AdminMonthlyRevenueVO> selectMonthlyRevenueList();
}
