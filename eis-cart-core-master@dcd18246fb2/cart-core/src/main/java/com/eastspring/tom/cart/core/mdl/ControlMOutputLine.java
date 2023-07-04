package com.eastspring.tom.cart.core.mdl;

import java.util.Objects;

/**
 * <p>This is the model that represents a single line of Control-M CTMORDER output line.</p>
 */
public class ControlMOutputLine {
    private ControlMOutputType type;
    private String folderName;
    private String jobName;
    private String orderid;
    private String leg;

    public ControlMOutputLine(ControlMOutputType type, String folderName, String jobName, String orderid) {
        this.type = type;
        this.folderName = folderName;
        this.jobName = jobName;
        this.orderid = orderid;
        this.leg = null;
    }

    public ControlMOutputType getType() {
        return type;
    }

    public String getFolderName() {
        return folderName;
    }

    public String getJobName() {
        return jobName;
    }

    public String getOrderid() {
        return orderid;
    }

    public String getLeg() {
        return leg;
    }

    public void setLeg(String leg) {
        this.leg = leg;
    }

    @Override
    public boolean equals(Object o) {
        if(this == o) return true;
        if(o == null || getClass() != o.getClass()) return false;
        ControlMOutputLine that = (ControlMOutputLine) o;
        return type == that.type &&
                Objects.equals(folderName, that.folderName) &&
                Objects.equals(jobName, that.jobName) &&
                Objects.equals(orderid, that.orderid) &&
                Objects.equals(leg, that.leg);
    }

    @Override
    public int hashCode() {
        return Objects.hash(type, folderName, jobName, orderid, leg);
    }
}
