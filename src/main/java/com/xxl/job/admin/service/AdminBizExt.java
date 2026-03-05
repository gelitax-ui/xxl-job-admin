package com.xxl.job.admin.service;

import com.xxl.job.admin.bean.CopyGroupAndJobParam;
import com.xxl.job.admin.bean.JobParam;
import com.xxl.job.admin.model.XxlJobInfo;
import com.xxl.job.core.openapi.AdminBiz;
import com.xxl.tool.response.Response;

public interface AdminBizExt extends AdminBiz {

    Response<String> copyGroupAndJob(CopyGroupAndJobParam param);

    Response<String> deleteGroupAndJob(String groupAppName);

    Response<String> jobAdd(JobParam param);

    Response<String> jobUpdate(JobParam param);

    Response<String> jobRemove(String groupAppName, String jobCode);

    Response<XxlJobInfo> jobQuery(String groupAppName, String jobCode);

    Response<String> jobResetTriggerTime(String groupAppName, String jobCode, String triggerTime);

}
