package com.xxl.job.admin.controller.biz;

import com.xxl.job.admin.mapper.XxlJobGroupMapper;
import com.xxl.job.admin.mapper.XxlJobInfoMapper;
import com.xxl.job.admin.model.XxlJobGroup;
import com.xxl.job.admin.model.XxlJobInfo;
import com.xxl.job.admin.scheduler.exception.XxlJobException;
import com.xxl.job.admin.scheduler.misfire.MisfireStrategyEnum;
import com.xxl.job.admin.scheduler.route.ExecutorRouteStrategyEnum;
import com.xxl.job.admin.scheduler.type.ScheduleTypeEnum;
import com.xxl.job.admin.service.XxlJobService;
import com.xxl.job.admin.util.I18nUtil;
import com.xxl.job.admin.util.JobGroupPermissionUtil;
import com.xxl.job.admin.util.PinyinUtil;
import com.xxl.job.core.constant.ExecutorBlockStrategyEnum;
import com.xxl.job.core.glue.GlueTypeEnum;
import com.xxl.sso.core.helper.XxlSsoHelper;
import com.xxl.sso.core.model.LoginInfo;
import com.xxl.tool.core.CollectionTool;
import com.xxl.tool.core.DateTool;
import com.xxl.tool.core.StringTool;
import com.xxl.tool.response.PageModel;
import com.xxl.tool.response.Response;
import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

/**
 * index controller
 * @author xuxueli 2015-12-19 16:13:16
 */
@Controller
@RequestMapping("/jobinfo")
public class JobInfoController {
	private static Logger logger = LoggerFactory.getLogger(JobInfoController.class);

	@Resource
	private XxlJobGroupMapper xxlJobGroupMapper;
	@Resource
	private XxlJobInfoMapper xxlJobInfoMapper;
	@Resource
	private XxlJobService xxlJobService;
	
	@RequestMapping
	public String index(HttpServletRequest request, Model model, @RequestParam(value = "jobGroup", required = false, defaultValue = "-1") int jobGroup) {

		// 枚举-字典
		model.addAttribute("ExecutorRouteStrategyEnum", ExecutorRouteStrategyEnum.values());	    // 路由策略-列表
		model.addAttribute("GlueTypeEnum", GlueTypeEnum.values());								// Glue类型-字典
		model.addAttribute("ExecutorBlockStrategyEnum", ExecutorBlockStrategyEnum.values());	    // 阻塞处理策略-字典
		model.addAttribute("ScheduleTypeEnum", ScheduleTypeEnum.values());	    				// 调度类型
		model.addAttribute("MisfireStrategyEnum", MisfireStrategyEnum.values());	    			// 调度过期策略

		// 执行器列表
		List<XxlJobGroup> jobGroupListTotal =  xxlJobGroupMapper.findAll();

		// filter group
		List<XxlJobGroup> jobGroupList = JobGroupPermissionUtil.filterJobGroupByPermission(request, jobGroupListTotal);
		if (CollectionTool.isEmpty(jobGroupList)) {
			throw new XxlJobException(I18nUtil.getString("jobgroup_empty"));
		}

		// parse jobGroup
		if (!(CollectionTool.isNotEmpty(jobGroupList)
				&& jobGroupList.stream().map(XxlJobGroup::getId).toList().contains(jobGroup))) {
			jobGroup = -1;
		}

		model.addAttribute("JobGroupList", jobGroupList);
		model.addAttribute("jobGroup", jobGroup);

		return "biz/job.list";
	}

	@RequestMapping("/pageList")
	@ResponseBody
	public Response<PageModel<XxlJobInfo>> pageList(HttpServletRequest request,
													@RequestParam(required = false, defaultValue = "0") int offset,
													@RequestParam(required = false, defaultValue = "10") int pagesize,
													@RequestParam int jobGroup,
													@RequestParam int triggerStatus,
													@RequestParam String jobDesc,
													@RequestParam(required = false, defaultValue = "") String jobCode,
													@RequestParam String executorHandler,
													@RequestParam String author) {

		// valid jobGroup permission
		JobGroupPermissionUtil.validJobGroupPermission(request, jobGroup);

		// page
		return xxlJobService.pageList(offset, pagesize, jobGroup, triggerStatus, jobDesc, jobCode, executorHandler, author);
	}
	
	@RequestMapping("/insert")
	@ResponseBody
	public Response<String> add(HttpServletRequest request, XxlJobInfo jobInfo,
								@RequestParam(value = "extraGroups", required = false) int[] extraGroups) {
		// valid permission
		LoginInfo loginInfo = JobGroupPermissionUtil.validJobGroupPermission(request, jobInfo.getJobGroup());

		// opt
		Response<String> result = xxlJobService.add(jobInfo, loginInfo);

		// sync to extra groups
		if (result.isSuccess() && extraGroups != null && extraGroups.length > 0) {
			for (int groupId : extraGroups) {
				XxlJobInfo copy = new XxlJobInfo();
				BeanUtils.copyProperties(jobInfo, copy);
				copy.setId(0);
				copy.setJobGroup(groupId);
				xxlJobService.add(copy, loginInfo);
			}
		}

		return result;
	}

	@RequestMapping("/update")
	@ResponseBody
	public Response<String> update(HttpServletRequest request, XxlJobInfo jobInfo,
								   @RequestParam(value = "extraGroups", required = false) int[] extraGroups) {
		// valid permission
		LoginInfo loginInfo = JobGroupPermissionUtil.validJobGroupPermission(request, jobInfo.getJobGroup());

		// opt
		Response<String> result = xxlJobService.update(jobInfo, loginInfo);

		// sync to extra groups
		if (result.isSuccess() && extraGroups != null && extraGroups.length > 0) {
			String originalCode = xxlJobInfoMapper.loadById(jobInfo.getId()).getJobCode();
			for (int groupId : extraGroups) {
				XxlJobInfo target = xxlJobInfoMapper.loadByGroupAndCode(groupId, originalCode);
				if (target != null) {
					XxlJobInfo updateJob = new XxlJobInfo();
					BeanUtils.copyProperties(jobInfo, updateJob);
					updateJob.setId(target.getId());
					updateJob.setJobGroup(groupId);
					xxlJobService.update(updateJob, loginInfo);
				}
			}
		}

		return result;
	}
	
	@RequestMapping("/delete")
	@ResponseBody
	public Response<String> delete(HttpServletRequest request, @RequestParam("ids[]") List<Integer> ids,
								   @RequestParam(value = "extraGroups", required = false) int[] extraGroups) {

		// valid
		if (CollectionTool.isEmpty(ids) || ids.size()!=1) {
			return Response.ofFail(I18nUtil.getString("system_please_choose") + I18nUtil.getString("system_one") + I18nUtil.getString("system_data"));
		}

		// get jobCode before delete
		XxlJobInfo jobInfo = xxlJobInfoMapper.loadById(ids.get(0));
		String jobCode = (jobInfo != null) ? jobInfo.getJobCode() : null;

		// check source: API-created jobs cannot be deleted from UI
		if (jobInfo != null && jobInfo.getSource() == 1) {
			return Response.ofFail("该任务由API创建，不允许在后台管理页面删除");
		}

		// invoke
		Response<LoginInfo> loginInfoResponse = XxlSsoHelper.loginCheckWithAttr(request);
		Response<String> result = xxlJobService.remove(ids.get(0), loginInfoResponse.getData());

		// sync to extra groups
		if (result.isSuccess() && extraGroups != null && extraGroups.length > 0 && StringTool.isNotBlank(jobCode)) {
			for (int groupId : extraGroups) {
				XxlJobInfo target = xxlJobInfoMapper.loadByGroupAndCode(groupId, jobCode);
				if (target != null) {
					xxlJobService.remove(target.getId(), loginInfoResponse.getData());
				}
			}
		}

		return result;
	}
	
	@RequestMapping("/stop")
	@ResponseBody
	public Response<String> pause(HttpServletRequest request, @RequestParam("ids[]") List<Integer> ids,
								  @RequestParam(value = "extraGroups", required = false) int[] extraGroups) {

		// valid
		if (CollectionTool.isEmpty(ids) || ids.size()!=1) {
			return Response.ofFail(I18nUtil.getString("system_please_choose") + I18nUtil.getString("system_one") + I18nUtil.getString("system_data"));
		}

		// invoke
		Response<LoginInfo> loginInfoResponse = XxlSsoHelper.loginCheckWithAttr(request);
		Response<String> result = xxlJobService.stop(ids.get(0), loginInfoResponse.getData());

		// sync to extra groups
		if (result.isSuccess() && extraGroups != null && extraGroups.length > 0) {
			XxlJobInfo jobInfo = xxlJobInfoMapper.loadById(ids.get(0));
			String jobCode = (jobInfo != null) ? jobInfo.getJobCode() : null;
			if (StringTool.isNotBlank(jobCode)) {
				for (int groupId : extraGroups) {
					XxlJobInfo target = xxlJobInfoMapper.loadByGroupAndCode(groupId, jobCode);
					if (target != null) {
						xxlJobService.stop(target.getId(), loginInfoResponse.getData());
					}
				}
			}
		}

		return result;
	}
	
	@RequestMapping("/start")
	@ResponseBody
	public Response<String> start(HttpServletRequest request, @RequestParam("ids[]") List<Integer> ids,
								  @RequestParam(value = "extraGroups", required = false) int[] extraGroups) {

		// valid
		if (CollectionTool.isEmpty(ids) || ids.size()!=1) {
			return Response.ofFail(I18nUtil.getString("system_please_choose") + I18nUtil.getString("system_one") + I18nUtil.getString("system_data"));
		}

		// invoke
		Response<LoginInfo> loginInfoResponse = XxlSsoHelper.loginCheckWithAttr(request);
		Response<String> result = xxlJobService.start(ids.get(0), loginInfoResponse.getData());

		// sync to extra groups
		if (result.isSuccess() && extraGroups != null && extraGroups.length > 0) {
			XxlJobInfo jobInfo = xxlJobInfoMapper.loadById(ids.get(0));
			String jobCode = (jobInfo != null) ? jobInfo.getJobCode() : null;
			if (StringTool.isNotBlank(jobCode)) {
				for (int groupId : extraGroups) {
					XxlJobInfo target = xxlJobInfoMapper.loadByGroupAndCode(groupId, jobCode);
					if (target != null) {
						xxlJobService.start(target.getId(), loginInfoResponse.getData());
					}
				}
			}
		}

		return result;
	}
	
	@RequestMapping("/trigger")
	@ResponseBody
	public Response<List<Map<String, Object>>> triggerJob(HttpServletRequest request,
									  @RequestParam("id") int id,
									  @RequestParam("executorParam") String executorParam,
									  @RequestParam("addressList") String addressList,
									  @RequestParam(value = "extraGroups", required = false) int[] extraGroups,
									  @RequestParam(value = "extraAddressList", required = false) String[] extraAddressList) {
		LoginInfo loginInfo = XxlSsoHelper.loginCheckWithAttr(request).getData();

		// build all trigger tasks
		List<CompletableFuture<Map<String, Object>>> futures = new ArrayList<>();

		// 1. main task
		XxlJobInfo mainJob = xxlJobInfoMapper.loadById(id);
		XxlJobGroup mainGroup = (mainJob != null) ? xxlJobGroupMapper.load(mainJob.getJobGroup()) : null;
		String mainGroupTitle = (mainGroup != null) ? mainGroup.getTitle() : ("执行器" + id);
		futures.add(CompletableFuture.supplyAsync(() -> {
			Map<String, Object> item = new LinkedHashMap<>();
			item.put("groupTitle", mainGroupTitle);
			try {
				Response<String> r = xxlJobService.trigger(loginInfo, id, executorParam, addressList);
				item.put("success", r.isSuccess());
				item.put("msg", r.isSuccess() ? "成功" : r.getMsg());
			} catch (Exception e) {
				item.put("success", false);
				item.put("msg", e.getMessage());
			}
			return item;
		}));

		// 2. extra group tasks
		if (extraGroups != null && extraGroups.length > 0) {
			String jobCode = (mainJob != null) ? mainJob.getJobCode() : null;
			if (StringTool.isNotBlank(jobCode)) {
				for (int i = 0; i < extraGroups.length; i++) {
					int groupId = extraGroups[i];
					String addr = (extraAddressList != null && i < extraAddressList.length) ? extraAddressList[i] : "";
					XxlJobInfo target = xxlJobInfoMapper.loadByGroupAndCode(groupId, jobCode);
					XxlJobGroup group = xxlJobGroupMapper.load(groupId);
					String groupTitle = (group != null) ? group.getTitle() : ("执行器" + groupId);

					if (target != null) {
						int targetId = target.getId();
						futures.add(CompletableFuture.supplyAsync(() -> {
							Map<String, Object> item = new LinkedHashMap<>();
							item.put("groupTitle", groupTitle);
							try {
								Response<String> r = xxlJobService.trigger(loginInfo, targetId, executorParam, addr);
								item.put("success", r.isSuccess());
								item.put("msg", r.isSuccess() ? "成功" : r.getMsg());
							} catch (Exception e) {
								item.put("success", false);
								item.put("msg", e.getMessage());
							}
							return item;
						}));
					} else {
						futures.add(CompletableFuture.completedFuture(Map.of(
								"groupTitle", groupTitle,
								"success", false,
								"msg", "未找到相同编码的任务"
						)));
					}
				}
			}
		}

		// wait all and collect results
		List<Map<String, Object>> results = futures.stream()
				.map(CompletableFuture::join)
				.toList();

		boolean allSuccess = results.stream().allMatch(r -> Boolean.TRUE.equals(r.get("success")));
		if (allSuccess) {
			return Response.ofSuccess(results);
		} else {
			Response<List<Map<String, Object>>> resp = Response.ofSuccess(results);
			resp.setCode(200);
			return resp;
		}
	}

	@RequestMapping("/groupsWithCode")
	@ResponseBody
	public Response<List<Integer>> groupsWithCode(@RequestParam("jobCode") String jobCode,
												  @RequestParam("excludeGroup") int excludeGroup) {
		List<Integer> groups = xxlJobInfoMapper.findGroupsByJobCode(jobCode, excludeGroup);
		return Response.ofSuccess(groups);
	}

	@RequestMapping("/generateCode")
	@ResponseBody
	public Response<String> generateCode(@RequestParam("jobDesc") String jobDesc) {
		if (StringTool.isBlank(jobDesc)) {
			return Response.ofFail("请输入任务描述");
		}
		String code = PinyinUtil.toPinyinCode(jobDesc);
		if (code.isEmpty()) {
			return Response.ofFail("无法生成编码，请手动输入");
		}
		return Response.ofSuccess(code);
	}

	@RequestMapping("/nextTriggerTime")
	@ResponseBody
	public Response<List<String>> nextTriggerTime(@RequestParam("scheduleType") String scheduleType,
												 @RequestParam("scheduleConf") String scheduleConf) {

		// valid
		if (StringTool.isBlank(scheduleType) || StringTool.isBlank(scheduleConf)) {
			return Response.ofSuccess(new ArrayList<>());
		}

		// param
		XxlJobInfo paramXxlJobInfo = new XxlJobInfo();
		paramXxlJobInfo.setScheduleType(scheduleType);
		paramXxlJobInfo.setScheduleConf(scheduleConf);

		// generate
		List<String> result = new ArrayList<>();
		try {
			Date lastTime = new Date();
			for (int i = 0; i < 5; i++) {

				// generate next trigger time
				ScheduleTypeEnum scheduleTypeEnum = ScheduleTypeEnum.match(paramXxlJobInfo.getScheduleType(), ScheduleTypeEnum.NONE);
				lastTime = scheduleTypeEnum.getScheduleType().generateNextTriggerTime(paramXxlJobInfo, lastTime);

				// collect data
				if (lastTime != null) {
					result.add(DateTool.formatDateTime(lastTime));
				} else {
					break;
				}
			}
		} catch (Exception e) {
			logger.error(">>>>>>>>>>> nextTriggerTime error. scheduleType = {}, scheduleConf= {}, error:{} ", scheduleType, scheduleConf, e.getMessage());
			return Response.ofFail((I18nUtil.getString("schedule_type")+I18nUtil.getString("system_unvalid")) + e.getMessage());
		}
		return Response.ofSuccess(result);

	}

}
