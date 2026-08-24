package meditrials.meditrials.admin.revenue.vo;

public class AdminMonthlyRevenueVO {

    private String monthLabel;
    private long paymentCount;
    private long premiumRevenue;

    public String getMonthLabel() {
        return monthLabel;
    }

    public void setMonthLabel(String monthLabel) {
        this.monthLabel = monthLabel;
    }

    public long getPaymentCount() {
        return paymentCount;
    }

    public void setPaymentCount(long paymentCount) {
        this.paymentCount = paymentCount;
    }

    public long getPremiumRevenue() {
        return premiumRevenue;
    }

    public void setPremiumRevenue(long premiumRevenue) {
        this.premiumRevenue = premiumRevenue;
    }
}
