package com.xxl.job.admin.service;

import com.xxl.job.admin.bean.CopyGroupAndJobParam;
import com.xxl.job.core.openapi.AdminBiz;
import com.xxl.tool.response.Response;

public interface AdminBizExt extends AdminBiz {

    Response<String> copyGroupAndJob(CopyGroupAndJobParam param);

    Response<String> deleteGroupAndJob(String groupAppName);

}
