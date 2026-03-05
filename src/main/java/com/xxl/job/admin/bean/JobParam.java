package com.xxl.job.admin.bean;

/**
 * OpenAPI 任务入参（精简 DTO，不暴露内部表结构）
 */
public class JobParam {

    // ---- 必填参数 ----
    private String groupAppName;        // 执行器AppName
    private String jobCode;             // 任务编码
    private String triggerTime;         // 执行时间（yyyy-MM-dd HH:mm:ss）
    private String executorHandler;     // JobHandler名称
    private String executorParam;       // 任务参数

    // ---- 选填参数 ----
    private String jobDesc;             // 任务描述
    private String author;              // 负责人
    private int executorTimeout;        // 超时时间（秒）
    private int executorFailRetryCount; // 失败重试次数
    private String remark;              // 备注

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

    public String getJobDesc() {
        return jobDesc;
    }

    public void setJobDesc(String jobDesc) {
        this.jobDesc = jobDesc;
    }

    public String getAuthor() {
        return author;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public String getTriggerTime() {
        return triggerTime;
    }

    public void setTriggerTime(String triggerTime) {
        this.triggerTime = triggerTime;
    }

    public String getExecutorHandler() {
        return executorHandler;
    }

    public void setExecutorHandler(String executorHandler) {
        this.executorHandler = executorHandler;
    }

    public String getExecutorParam() {
        return executorParam;
    }

    public void setExecutorParam(String executorParam) {
        this.executorParam = executorParam;
    }

    public int getExecutorTimeout() {
        return executorTimeout;
    }

    public void setExecutorTimeout(int executorTimeout) {
        this.executorTimeout = executorTimeout;
    }

    public int getExecutorFailRetryCount() {
        return executorFailRetryCount;
    }

    public void setExecutorFailRetryCount(int executorFailRetryCount) {
        this.executorFailRetryCount = executorFailRetryCount;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }
}
