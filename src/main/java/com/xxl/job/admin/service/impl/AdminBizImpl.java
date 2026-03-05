package com.xxl.job.admin.service.impl;

import com.xxl.job.admin.bean.CopyGroupAndJobParam;
import com.xxl.job.admin.bean.JobParam;
import com.xxl.job.admin.mapper.XxlJobGroupMapper;
import com.xxl.job.admin.mapper.XxlJobInfoMapper;
import com.xxl.job.admin.model.XxlJobGroup;
import com.xxl.job.admin.model.XxlJobInfo;
import com.xxl.job.admin.scheduler.config.XxlJobAdminBootstrap;
import com.xxl.job.admin.service.AdminBizExt;
import com.xxl.job.admin.service.XxlJobService;
import com.xxl.job.core.openapi.model.CallbackRequest;
import com.xxl.job.core.openapi.model.RegistryRequest;
import com.xxl.sso.core.model.LoginInfo;
import com.xxl.tool.response.Response;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import java.util.List;

/**
 * @author xuxueli 2017-07-27 21:54:20
 */
@Service
public class AdminBizImpl implements AdminBizExt {

    @Resource
    private XxlJobInfoMapper xxlJobInfoMapper;

    @Resource
    private XxlJobGroupMapper xxlJobGroupMapper;

    @Resource
    private XxlJobService xxlJobService;

    @Override
    public Response<String> callback(List<CallbackRequest> callbackRequestList) {
        return XxlJobAdminBootstrap.getInstance().getJobCompleteHelper().callback(callbackRequestList);
    }

    @Override
    public Response<String> registry(RegistryRequest registryRequest) {
        return XxlJobAdminBootstrap.getInstance().getJobRegistryHelper().registry(registryRequest);
    }

    @Override
    public Response<String> registryRemove(RegistryRequest registryRequest) {
        return XxlJobAdminBootstrap.getInstance().getJobRegistryHelper().registryRemove(registryRequest);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Response<String> copyGroupAndJob(CopyGroupAndJobParam param) {
        if (StringUtils.isEmpty(param.getGroupAppName()) || StringUtils.isEmpty(param.getGroupTitle()) || StringUtils.isEmpty(param.getModeGroupAppName())) {
            return Response.ofFail( "param is error.");
        }
        //先判断组是否粗壮
        XxlJobGroup xxlJobGroupOld = xxlJobGroupMapper.findByAppName(param.getGroupAppName());
        if (xxlJobGroupOld != null) {
            this.deleteGroupAndJob(param.getGroupAppName());
        }
        XxlJobGroup xxlJobGroup = xxlJobGroupMapper.findByAppName(param.getModeGroupAppName());
        if (xxlJobGroup == null) {
            return Response.ofFail( "mode group does not exist.");
        }
        List<XxlJobInfo> jobInfoList = xxlJobInfoMapper.getJobsByGroup(xxlJobGroup.getId());

        //复制
        xxlJobGroup.setId(0);
        xxlJobGroup.setAppname(param.getGroupAppName());
        xxlJobGroup.setTitle(param.getGroupTitle());
        xxlJobGroup.setAddressList(null);
        xxlJobGroupMapper.save(xxlJobGroup);
        if (xxlJobGroup.getId() == 0) {
            return Response.ofFail( "add group error.");
        }

        if (!CollectionUtils.isEmpty(jobInfoList)) {
            LoginInfo loginInfo = new LoginInfo();
            loginInfo.setUserName("api");
            for (XxlJobInfo xxlJobInfo : jobInfoList) {
                xxlJobInfo.setId(0);
                xxlJobInfo.setJobGroup(xxlJobGroup.getId());
                xxlJobInfo.setSource(1);
                xxlJobService.add(xxlJobInfo,loginInfo);
            }
        }
        return Response.ofSuccess("copy group and job success.");
    }

    @Override
    public Response<String> deleteGroupAndJob(String groupAppName) {
        XxlJobGroup xxlJobGroup = xxlJobGroupMapper.findByAppName(groupAppName);
        List<XxlJobInfo> jobInfoList = xxlJobInfoMapper.getJobsByGroup(xxlJobGroup.getId());
        if (!CollectionUtils.isEmpty(jobInfoList)) {
            LoginInfo loginInfo = new LoginInfo();
            loginInfo.setUserName("api");
            for (XxlJobInfo xxlJobInfo : jobInfoList) {
                xxlJobService.remove(xxlJobInfo.getId(),loginInfo);
            }
        }
        xxlJobGroupMapper.remove(xxlJobGroup.getId());
        return Response.ofSuccess("delete group and job success.");
    }

    private LoginInfo apiLoginInfo() {
        LoginInfo loginInfo = new LoginInfo();
        loginInfo.setUserName("api");
        return loginInfo;
    }

    private int resolveJobGroup(String groupAppName) {
        if (groupAppName == null || groupAppName.isEmpty()) {
            return 0;
        }
        XxlJobGroup group = xxlJobGroupMapper.findByAppName(groupAppName);
        return group != null ? group.getId() : 0;
    }

    private XxlJobInfo convertParam(JobParam param, int jobGroup) {
        XxlJobInfo jobInfo = new XxlJobInfo();
        jobInfo.setJobGroup(jobGroup);
        jobInfo.setJobCode(param.getJobCode());
        jobInfo.setJobDesc(param.getJobDesc());
        jobInfo.setAuthor(param.getAuthor());
        jobInfo.setScheduleType("ONCE");
        jobInfo.setScheduleConf(param.getTriggerTime());
        jobInfo.setGlueType("BEAN");
        jobInfo.setExecutorHandler(param.getExecutorHandler());
        jobInfo.setExecutorParam(param.getExecutorParam());
        jobInfo.setExecutorRouteStrategy("CONSISTENT_HASH");
        jobInfo.setExecutorBlockStrategy("SERIAL_EXECUTION");
        jobInfo.setMisfireStrategy("DO_NOTHING");
        jobInfo.setExecutorTimeout(param.getExecutorTimeout());
        jobInfo.setExecutorFailRetryCount(param.getExecutorFailRetryCount());
        jobInfo.setRemark(param.getRemark());
        return jobInfo;
    }

    @Override
    public Response<String> jobAdd(JobParam param) {
        int jobGroup = resolveJobGroup(param.getGroupAppName());
        if (jobGroup == 0) {
            return Response.ofFail("执行器不存在, groupAppName=" + param.getGroupAppName());
        }
        XxlJobInfo jobInfo = convertParam(param, jobGroup);
        jobInfo.setSource(1);
        LoginInfo loginInfo = apiLoginInfo();
        Response<String> addResult = xxlJobService.add(jobInfo, loginInfo);
        if (addResult.isSuccess()) {
            int jobId = Integer.parseInt(addResult.getData());
            xxlJobService.start(jobId, loginInfo);
        }
        return addResult;
    }

    @Override
    public Response<String> jobUpdate(JobParam param) {
        int jobGroup = resolveJobGroup(param.getGroupAppName());
        if (jobGroup == 0) {
            return Response.ofFail("执行器不存在, groupAppName=" + param.getGroupAppName());
        }
        XxlJobInfo existJob = xxlJobInfoMapper.loadByGroupAndCode(jobGroup, param.getJobCode());
        if (existJob == null) {
            return Response.ofFail("job not found, groupAppName=" + param.getGroupAppName() + ", jobCode=" + param.getJobCode());
        }
        if (existJob.getSource() != 1) {
            return Response.ofFail("该任务由后台管理创建，不允许通过API修改");
        }
        XxlJobInfo jobInfo = convertParam(param, jobGroup);
        jobInfo.setId(existJob.getId());
        jobInfo.setSource(1);
        LoginInfo loginInfo = apiLoginInfo();
        Response<String> updateResult = xxlJobService.update(jobInfo, loginInfo);
        if (updateResult.isSuccess()) {
            xxlJobService.start(existJob.getId(), loginInfo);
        }
        return updateResult;
    }

    @Override
    public Response<String> jobRemove(String groupAppName, String jobCode) {
        int jobGroup = resolveJobGroup(groupAppName);
        if (jobGroup == 0) {
            return Response.ofFail("执行器不存在, groupAppName=" + groupAppName);
        }
        XxlJobInfo jobInfo = xxlJobInfoMapper.loadByGroupAndCode(jobGroup, jobCode);
        if (jobInfo == null) {
            return Response.ofFail("job not found, groupAppName=" + groupAppName + ", jobCode=" + jobCode);
        }
        if (jobInfo.getSource() != 1) {
            return Response.ofFail("该任务由后台管理创建，不允许通过API删除");
        }
        return xxlJobService.remove(jobInfo.getId(), apiLoginInfo());
    }

    @Override
    public Response<XxlJobInfo> jobQuery(String groupAppName, String jobCode) {
        int jobGroup = resolveJobGroup(groupAppName);
        if (jobGroup == 0) {
            return Response.ofFail("执行器不存在, groupAppName=" + groupAppName);
        }
        XxlJobInfo jobInfo = xxlJobInfoMapper.loadByGroupAndCode(jobGroup, jobCode);
        if (jobInfo == null) {
            return Response.ofFail("job not found, groupAppName=" + groupAppName + ", jobCode=" + jobCode);
        }
        return Response.ofSuccess(jobInfo);
    }

}
