package com.xxl.job.admin.bean;

public class JobIdParam {

    private String groupAppName;
    private String jobCode;
    private String triggerTime;     // 用于 jobResetTriggerTime

    public String getGroupAppName() {
        return groupAppName;
    }

    public void setGroupAppName(String groupAppName) {
        this.groupAppName = groupAppName;
    }

    public String getJobCode() {
        return jobCode;
    }

    public void setJobCode(String jobCode) {
        this.jobCode = jobCode;
    }

    public String getTriggerTime() {
        return triggerTime;
    }

    public void setTriggerTime(String triggerTime) {
        this.triggerTime = triggerTime;
    }
}
