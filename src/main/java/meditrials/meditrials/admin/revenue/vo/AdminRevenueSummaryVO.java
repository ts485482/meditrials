package meditrials.meditrials.admin.revenue.vo;

public class AdminRevenueSummaryVO {

    private long currentMonthRevenue;
    private long previousMonthRevenue;
    private long currentMonthPaymentCount;
    private long activePremiumCount;
    private long totalPaidRevenue;

    public long getCurrentMonthRevenue() {
        return currentMonthRevenue;
    }

    public void setCurrentMonthRevenue(long currentMonthRevenue) {
        this.currentMonthRevenue = currentMonthRevenue;
    }

    public long getPreviousMonthRevenue() {
        return previousMonthRevenue;
    }

    public void setPreviousMonthRevenue(long previousMonthRevenue) {
        this.previousMonthRevenue = previousMonthRevenue;
    }

    public long getCurrentMonthPaymentCount() {
        return currentMonthPaymentCount;
    }

    public void setCurrentMonthPaymentCount(long currentMonthPaymentCount) {
        this.currentMonthPaymentCount = currentMonthPaymentCount;
    }

    public long getActivePremiumCount() {
        return activePremiumCount;
    }

    public void setActivePremiumCount(long activePremiumCount) {
        this.activePremiumCount = activePremiumCount;
    }

    public long getTotalPaidRevenue() {
        return totalPaidRevenue;
    }

    public void setTotalPaidRevenue(long totalPaidRevenue) {
        this.totalPaidRevenue = totalPaidRevenue;
    }
}
