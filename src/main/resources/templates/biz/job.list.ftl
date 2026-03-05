<!DOCTYPE html>
<html>
<head>
	<#-- import macro -->
	<#import "../common/common.macro.ftl" as netCommon>

	<!-- 1-style start -->
	<@netCommon.commonStyle />
	<link rel="stylesheet" href="${request.contextPath}/static/plugins/bootstrap-table/bootstrap-table.min.css">
	<link rel="stylesheet" href="${request.contextPath}/static/adminlte/bower_components/select2/select2.min.css">
	<style>
		.select2-container--default .select2-selection--multiple .select2-selection__choice {
			color: #333;
			background-color: #e4e4e4;
			border-color: #aaa;
		}
	</style>
	<!-- 1-style end -->

</head>
<body class="hold-transition" style="background-color: #ecf0f5;">
<div class="wrapper">
	<section class="content">

		<!-- 2-content start -->

		<#-- 查询区域 -->
		<div class="box" style="margin-bottom:9px;">
			<div class="box-body">
				<div class="row" id="data_filter" >

					<div class="col-xs-3">
						<div class="input-group">
							<span class="input-group-addon">${I18n.jobinfo_field_jobgroup}</span>
							<select class="form-control" id="jobGroup" >
								<#list JobGroupList as group>
									<option value="${group.id}" <#if jobGroup==group.id>selected</#if> >${group.title}</option>
								</#list>
							</select>
						</div>
					</div>
					<div class="col-xs-1">
						<div class="input-group">
							<select class="form-control" id="triggerStatus" >
								<option value="-1" >${I18n.system_all}</option>
								<option value="0" >${I18n.jobinfo_opt_stop}</option>
								<option value="1" >${I18n.jobinfo_opt_start}</option>
							</select>
						</div>
					</div>
					<div class="col-xs-2">
						<div class="input-group">
							<input type="text" class="form-control" id="jobDesc" placeholder="${I18n.system_please_input}${I18n.jobinfo_field_jobdesc}" >
						</div>
					</div>
					<div class="col-xs-2">
						<div class="input-group">
							<input type="text" class="form-control" id="jobCode" placeholder="${I18n.system_please_input}任务编码" >
						</div>
					</div>
					<div class="col-xs-2">
						<div class="input-group">
							<input type="text" class="form-control" id="executorHandler" placeholder="${I18n.system_please_input}JobHandler" >
						</div>
					</div>
					<div class="col-xs-2">
						<div class="input-group">
							<input type="text" class="form-control" id="author" placeholder="${I18n.system_please_input}${I18n.jobinfo_field_author}" >
						</div>
					</div>

					<div class="col-xs-1">
						<button class="btn btn-block btn-primary searchBtn" >${I18n.system_search}</button>
					</div>
					<div class="col-xs-1">
						<button class="btn btn-block btn-default resetBtn" >${I18n.system_reset}</button>
					</div>
				</div>
			</div>
		</div>

		<#-- 数据表格区域 -->
		<div class="row">
			<div class="col-xs-12">
				<div class="box">
					<div class="box-header pull-left" id="data_operation" >
						<button class="btn btn-sm btn-info add" type="button"><i class="fa fa-plus" ></i>${I18n.system_opt_add}</button>                        <#-- add -->
						<button class="btn btn-sm btn-warning selectOnlyOne update" type="button"><i class="fa fa-edit"></i>${I18n.system_opt_edit}</button>    <#-- update -->
                        <button class="btn btn-sm btn-warning selectOnlyOne glue_ide" type="button">GLUE IDE</button>									        <#-- GLUE IDE：'BEAN' != row.glueType -->
						<button class="btn btn-sm btn-danger selectOnlyOne delete" type="button"><i class="fa fa-remove "></i>${I18n.system_opt_del}</button>   <#-- delete -->
						｜
						<button class="btn btn-sm btn-default selectOnlyOne job_copy" type="button">${I18n.system_opt_copy}</button>
						<button class="btn btn-sm btn-warning selectAny job_resume" type="button">${I18n.jobinfo_opt_start}</button>				<#-- 启动 -->
						<button class="btn btn-sm btn-warning selectAny job_pause" type="button">${I18n.jobinfo_opt_stop}</button>					<#-- 停止 -->
						｜
						<button class="btn btn-sm btn-primary selectOnlyOne job_trigger" type="button">${I18n.jobinfo_opt_run}</button>					<#-- 执行一次 -->
						<button class="btn btn-sm btn-primary selectOnlyOne job_log" type="button">${I18n.jobinfo_opt_log}</button>						<#-- 执行日志：base_url +'/joblog?jobId='+ row.id -->
						<button class="btn btn-sm btn-default selectOnlyOne job_registryinfo" type="button">${I18n.jobinfo_opt_registryinfo}</button>	<#-- 注册节点 -->
						<button class="btn btn-sm btn-default selectOnlyOne job_next_time" type="button">${I18n.jobinfo_opt_next_time}</button>			<#-- 下次执行时间：row.scheduleType == 'CRON' || row.scheduleType == 'FIX_RATE' -->
					</div>
					<div class="box-body" >
						<table id="data_list" class="table table-bordered table-striped" width="100%" >
							<thead></thead>
							<tbody></tbody>
							<tfoot></tfoot>
						</table>
					</div>
				</div>
			</div>
		</div>

		<!-- job新增.模态框 -->
		<div class="modal fade" id="addModal" tabindex="-1" role="dialog"  aria-hidden="true">
			<div class="modal-dialog modal-lg">
				<div class="modal-content">
					<div class="modal-header">
						<h4 class="modal-title" >${I18n.jobinfo_field_add}</h4>
					</div>
					<div class="modal-body">
						<form class="form-horizontal form" role="form" >

							<p style="margin: 0 0 10px;text-align: left;border-bottom: 1px solid #e5e5e5;color: gray;">${I18n.jobinfo_conf_base}</p>    <#-- 基础信息 -->
							<div class="form-group">
								<label for="firstname" class="col-sm-2 control-label">${I18n.jobinfo_field_jobgroup}<font color="red">*</font></label>
								<div class="col-sm-4">
									<select class="form-control" name="jobGroup" >
										<#list JobGroupList as group>
											<option value="${group.id}" <#if jobGroup==group.id>selected</#if> >${group.title}</option>
										</#list>
									</select>
								</div>

								<label for="lastname" class="col-sm-2 control-label">${I18n.jobinfo_field_jobdesc}<font color="red">*</font></label>
								<div class="col-sm-4"><input type="text" class="form-control" name="jobDesc" placeholder="${I18n.system_please_input}${I18n.jobinfo_field_jobdesc}" maxlength="50" ></div>
							</div>
							<div class="form-group">
								<label class="col-sm-2 control-label">任务编码<font color="red">*</font></label>
								<div class="col-sm-4">
									<div class="input-group">
										<input type="text" class="form-control" name="jobCode" placeholder="请输入任务编码（字母或数字）" maxlength="64" >
										<span class="input-group-btn">
											<button type="button" class="btn btn-default generateJobCode">生成</button>
										</span>
									</div>
								</div>
								<label for="lastname" class="col-sm-2 control-label">${I18n.jobinfo_field_author}<font color="red">*</font></label>
								<div class="col-sm-4"><input type="text" class="form-control" name="author" placeholder="${I18n.system_please_input}${I18n.jobinfo_field_author}" maxlength="50" ></div>
							</div>
							<div class="form-group">
								<label for="lastname" class="col-sm-2 control-label">${I18n.jobinfo_field_alarmemail}<font color="black">*</font></label>
								<div class="col-sm-4"><input type="text" class="form-control" name="alarmEmail" placeholder="${I18n.jobinfo_field_alarmemail_placeholder}" maxlength="100" ></div>
								<label for="firstname" class="col-sm-2 control-label">${I18n.jobinfo_field_remark}<font color="black">*</font></label>
								<div class="col-sm-4">
									<input type="text" class="form-control" name="remark" placeholder="${I18n.system_please_input}${I18n.jobinfo_field_remark}" maxlength="255" >
								</div>
							</div>
							<div class="form-group">
								<label class="col-sm-2 control-label">同步执行器</label>
								<div class="col-sm-10">
									<select class="form-control extraGroups" name="extraGroups" multiple="multiple" style="width:100%">
										<#list JobGroupList as group>
											<option value="${group.id}">${group.title}</option>
										</#list>
									</select>
								</div>
							</div>

							<br>
							<p style="margin: 0 0 10px;text-align: left;border-bottom: 1px solid #e5e5e5;color: gray;">${I18n.jobinfo_conf_schedule}</p>    <#-- 调度 -->
							<div class="form-group">
								<label for="firstname" class="col-sm-2 control-label">${I18n.schedule_type}<font color="red">*</font></label>
								<div class="col-sm-4">
									<select class="form-control scheduleType" name="scheduleType" >
										<#list ScheduleTypeEnum as item>
											<option value="${item}" <#if 'CRON' == item >selected</#if> >${item.title}</option>
										</#list>
									</select>
								</div>

								<input type="hidden" name="scheduleConf" />
								<div class="schedule_conf schedule_conf_NONE" style="display: none" >
								</div>
								<div class="schedule_conf schedule_conf_CRON" >
									<label for="lastname" class="col-sm-2 control-label">Cron<font color="red">*</font></label>
									<div class="col-sm-4"><input type="text" class="form-control" name="schedule_conf_CRON" placeholder="${I18n.system_please_input}Cron" maxlength="128" ></div>
								</div>
								<div class="schedule_conf schedule_conf_FIX_RATE" style="display: none" >
									<label for="lastname" class="col-sm-2 control-label">${I18n.schedule_type_fix_rate}<font color="red">*</font></label>
									<div class="col-sm-4"><input type="text" class="form-control" name="schedule_conf_FIX_RATE" placeholder="${I18n.system_please_input} （ Second ）" maxlength="10" onkeyup="this.value=this.value.replace(/\D/g,'')" onafterpaste="this.value=this.value.replace(/\D/g,'')" ></div>
								</div>
								<div class="schedule_conf schedule_conf_FIX_DELAY" style="display: none" >
									<label for="lastname" class="col-sm-2 control-label">${I18n.schedule_type_fix_delay}<font color="red">*</font></label>
									<div class="col-sm-4"><input type="text" class="form-control" name="schedule_conf_FIX_DELAY" placeholder="${I18n.system_please_input} （ Second ）" maxlength="10" onkeyup="this.value=this.value.replace(/\D/g,'')" onafterpaste="this.value=this.value.replace(/\D/g,'')" ></div>
								</div>
								<div class="schedule_conf schedule_conf_ONCE" style="display: none" >
									<label for="lastname" class="col-sm-2 control-label">${I18n.schedule_type_once}<font color="red">*</font></label>
									<div class="col-sm-4"><input type="text" class="form-control" name="schedule_conf_ONCE" placeholder="yyyy-MM-dd HH:mm:ss" maxlength="19" ></div>
								</div>
							</div>

							<br>
							<p style="margin: 0 0 10px;text-align: left;border-bottom: 1px solid #e5e5e5;color: gray;">${I18n.jobinfo_conf_job}</p>    <#-- 任务配置 -->

							<div class="form-group">
								<label for="firstname" class="col-sm-2 control-label">${I18n.jobinfo_field_gluetype}<font color="red">*</font></label>
								<div class="col-sm-4">
									<select class="form-control glueType" name="glueType" >
										<#list GlueTypeEnum as item>
											<option value="${item}" >${item.desc}</option>
										</#list>
									</select>
								</div>
								<label for="firstname" class="col-sm-2 control-label">JobHandler<font color="red">*</font></label>
								<div class="col-sm-4"><input type="text" class="form-control" name="executorHandler" placeholder="${I18n.system_please_input}JobHandler" maxlength="100" ></div>
							</div>

							<div class="form-group">
								<label for="firstname" class="col-sm-2 control-label">${I18n.jobinfo_field_executorparam}<font color="black">*</font></label>
								<div class="col-sm-10">
									<textarea class="textarea form-control" name="executorParam" placeholder="${I18n.system_please_input}${I18n.jobinfo_field_executorparam}" maxlength="512" style="height: 63px; line-height: 1.2;"></textarea>
								</div>
							</div>

							<br>
							<p style="margin: 0 0 10px;text-align: left;border-bottom: 1px solid #e5e5e5;color: gray;">${I18n.jobinfo_conf_advanced}</p>    <#-- 高级配置 -->

							<div class="form-group">
								<label for="firstname" class="col-sm-2 control-label">${I18n.jobinfo_field_executorRouteStrategy}<font color="black">*</font></label>
								<div class="col-sm-4">
									<select class="form-control" name="executorRouteStrategy" >
										<#list ExecutorRouteStrategyEnum as item>
											<option value="${item}" >${item.title}</option>
										</#list>
									</select>
								</div>

								<label for="lastname" class="col-sm-2 control-label">${I18n.jobinfo_field_childJobId}<font color="black">*</font></label>
								<div class="col-sm-4"><input type="text" class="form-control" name="childJobId" placeholder="${I18n.jobinfo_field_childJobId_placeholder}" maxlength="100" ></div>
							</div>

							<div class="form-group">
								<label for="firstname" class="col-sm-2 control-label">${I18n.misfire_strategy}<font color="black">*</font></label>
								<div class="col-sm-4">
									<select class="form-control" name="misfireStrategy" >
										<#list MisfireStrategyEnum as item>
											<option value="${item}" <#if 'DO_NOTHING' == item >selected</#if> >${item.title}</option>
										</#list>
									</select>
								</div>

								<label for="firstname" class="col-sm-2 control-label">${I18n.jobinfo_field_executorBlockStrategy}<font color="black">*</font></label>
								<div class="col-sm-4">
									<select class="form-control" name="executorBlockStrategy" >
										<#list ExecutorBlockStrategyEnum as item>
											<option value="${item}" >${item.title}</option>
										</#list>
									</select>
								</div>
							</div>

							<div class="form-group">
								<label for="lastname" class="col-sm-2 control-label">${I18n.jobinfo_field_timeout}<font color="black">*</font></label>
								<div class="col-sm-4"><input type="text" class="form-control" name="executorTimeout" placeholder="${I18n.jobinfo_field_executorTimeout_placeholder}" maxlength="6" onkeyup="this.value=this.value.replace(/\D/g,'')" onafterpaste="this.value=this.value.replace(/\D/g,'')" ></div>
								<label for="lastname" class="col-sm-2 control-label">${I18n.jobinfo_field_executorFailRetryCount}<font color="black">*</font></label>
								<div class="col-sm-4"><input type="text" class="form-control" name="executorFailRetryCount" placeholder="${I18n.jobinfo_field_executorFailRetryCount_placeholder}" maxlength="4" onkeyup="this.value=this.value.replace(/\D/g,'')" onafterpaste="this.value=this.value.replace(/\D/g,'')" ></div>
							</div>

							<hr>
							<div class="form-group">
								<div class="col-sm-offset-3 col-sm-6">
									<button type="submit" class="btn btn-primary"  >${I18n.system_save}</button>
									<button type="button" class="btn btn-default" data-dismiss="modal">${I18n.system_cancel}</button>
								</div>
							</div>

<input type="hidden" name="glueRemark" value="GLUE代码初始化" >
<textarea name="glueSource" style="display:none;" ></textarea>
<textarea class="glueSource_java" style="display:none;" >
package com.xxl.job.service.handler;

import com.xxl.job.core.context.XxlJobHelper;
import com.xxl.job.core.handler.IJobHandler;

public class DemoGlueJobHandler extends IJobHandler {

	@Override
	public void execute() throws Exception {
		XxlJobHelper.log("XXL-JOB, Hello World.");
	}

}
</textarea>
<textarea class="glueSource_shell" style="display:none;" >
#!/bin/bash
echo "xxl-job: hello shell"

echo "${I18n.jobinfo_script_location}：$0"
echo "${I18n.jobinfo_field_executorparam}：$1"
echo "${I18n.jobinfo_shard_index} = $2"
echo "${I18n.jobinfo_shard_total} = $3"
<#--echo "参数数量：$#"
for param in $*
do
    echo "参数 : $param"
    sleep 1s
done-->

echo "Good bye!"
exit 0
</textarea>
<textarea class="glueSource_python" style="display:none;" >
#!/usr/bin/python
# -*- coding: UTF-8 -*-
import time
import sys

print("xxl-job: hello python")

print("${I18n.jobinfo_script_location}：", sys.argv[0])
print("${I18n.jobinfo_field_executorparam}：", sys.argv[1])
print("${I18n.jobinfo_shard_index}：", sys.argv[2])
print("${I18n.jobinfo_shard_total}：", sys.argv[3])

print("Good bye!")
exit(0)
</textarea>
<textarea class="glueSource_python2" style="display:none;" >
#!/usr/bin/python
# -*- coding: UTF-8 -*-
import time
import sys

print "xxl-job: hello python"

print "${I18n.jobinfo_script_location}：", sys.argv[0]
print "${I18n.jobinfo_field_executorparam}：", sys.argv[1]
print "${I18n.jobinfo_shard_index}：", sys.argv[2]
print "${I18n.jobinfo_shard_total}：", sys.argv[3]
<#--for i in range(1, len(sys.argv)):
	time.sleep(1)
	print "参数", i, sys.argv[i]-->

print "Good bye!"
exit(0)
<#--
import logging
logging.basicConfig(level=logging.DEBUG)
logging.info("脚本文件：" + sys.argv[0])
-->
</textarea>
<textarea class="glueSource_php" style="display:none;" >
<?php

    echo "xxl-job: hello php  \n";

    echo "${I18n.jobinfo_script_location}：$argv[0]  \n";
    echo "${I18n.jobinfo_field_executorparam}：$argv[1]  \n";
    echo "${I18n.jobinfo_shard_index} = $argv[2]  \n";
    echo "${I18n.jobinfo_shard_total} = $argv[3]  \n";

    echo "Good bye!  \n";
    exit(0);

?>
</textarea>
<textarea class="glueSource_nodejs" style="display:none;" >
#!/usr/bin/env node
console.log("xxl-job: hello nodejs")

var arguments = process.argv

console.log("${I18n.jobinfo_script_location}: " + arguments[1])
console.log("${I18n.jobinfo_field_executorparam}: " + arguments[2])
console.log("${I18n.jobinfo_shard_index}: " + arguments[3])
console.log("${I18n.jobinfo_shard_total}: " + arguments[4])
<#--for (var i = 2; i < arguments.length; i++){
	console.log("参数 %s = %s", (i-1), arguments[i]);
}-->

console.log("Good bye!")
process.exit(0)
</textarea>
<textarea class="glueSource_powershell" style="display:none;" >
Write-Host "xxl-job: hello powershell"

Write-Host "${I18n.jobinfo_script_location}: " $MyInvocation.MyCommand.Definition
Write-Host "${I18n.jobinfo_field_executorparam}: "
	if ($args.Count -gt 2) { $args[0..($args.Count-3)] }
Write-Host "${I18n.jobinfo_shard_index}: " $args[$args.Count-2]
Write-Host "${I18n.jobinfo_shard_total}: " $args[$args.Count-1]

Write-Host "Good bye!"
exit 0
</textarea>
						</form>
					</div>
				</div>
			</div>
		</div>

		<!-- 更新.模态框 -->
		<div class="modal fade" id="updateModal" tabindex="-1" role="dialog"  aria-hidden="true">
			<div class="modal-dialog modal-lg">
				<div class="modal-content">
					<div class="modal-header">
						<h4 class="modal-title" >${I18n.jobinfo_field_update}</h4>
					</div>
					<div class="modal-body">
						<form class="form-horizontal form" role="form" >

							<p style="margin: 0 0 10px;text-align: left;border-bottom: 1px solid #e5e5e5;color: gray;">${I18n.jobinfo_conf_base}</p>    <#-- 基础信息 -->
							<div class="form-group">
								<label for="firstname" class="col-sm-2 control-label">${I18n.jobinfo_field_jobgroup}<font color="red">*</font></label>
								<div class="col-sm-4">
									<select class="form-control" name="jobGroup" >
										<#list JobGroupList as group>
											<option value="${group.id}" >${group.title}</option>
										</#list>
									</select>
								</div>

								<label for="lastname" class="col-sm-2 control-label">${I18n.jobinfo_field_jobdesc}<font color="red">*</font></label>
								<div class="col-sm-4"><input type="text" class="form-control" name="jobDesc" placeholder="${I18n.system_please_input}${I18n.jobinfo_field_jobdesc}" maxlength="50" ></div>
							</div>
							<div class="form-group">
								<label class="col-sm-2 control-label">任务编码<font color="red">*</font></label>
								<div class="col-sm-4">
									<div class="input-group">
										<input type="text" class="form-control" name="jobCode" placeholder="请输入任务编码（字母或数字）" maxlength="64" >
										<span class="input-group-btn">
											<button type="button" class="btn btn-default generateJobCode">生成</button>
										</span>
									</div>
								</div>
								<label for="lastname" class="col-sm-2 control-label">${I18n.jobinfo_field_author}<font color="red">*</font></label>
								<div class="col-sm-4"><input type="text" class="form-control" name="author" placeholder="${I18n.system_please_input}${I18n.jobinfo_field_author}" maxlength="50" ></div>
							</div>
							<div class="form-group">
								<label for="lastname" class="col-sm-2 control-label">${I18n.jobinfo_field_alarmemail}<font color="black">*</font></label>
								<div class="col-sm-4"><input type="text" class="form-control" name="alarmEmail" placeholder="${I18n.jobinfo_field_alarmemail_placeholder}" maxlength="100" ></div>
								<label for="firstname" class="col-sm-2 control-label">${I18n.jobinfo_field_remark}<font color="black">*</font></label>
								<div class="col-sm-4">
									<input type="text" class="form-control" name="remark" placeholder="${I18n.system_please_input}${I18n.jobinfo_field_remark}" maxlength="255" >
								</div>
							</div>
							<div class="form-group">
								<label class="col-sm-2 control-label">同步执行器</label>
								<div class="col-sm-10">
									<select class="form-control extraGroups" name="extraGroups" multiple="multiple" style="width:100%">
									</select>
								</div>
							</div>

							<br>
							<p style="margin: 0 0 10px;text-align: left;border-bottom: 1px solid #e5e5e5;color: gray;">${I18n.jobinfo_conf_schedule}</p>    <#-- 调度配置 -->
							<div class="form-group">
								<label for="firstname" class="col-sm-2 control-label">${I18n.schedule_type}<font color="red">*</font></label>
								<div class="col-sm-4">
									<select class="form-control scheduleType" name="scheduleType" >
										<#list ScheduleTypeEnum as item>
											<option value="${item}" >${item.title}</option>
										</#list>
									</select>
								</div>

								<input type="hidden" name="scheduleConf" />
								<div class="schedule_conf schedule_conf_NONE" style="display: none" >
								</div>
								<div class="schedule_conf schedule_conf_CRON" >
									<label for="lastname" class="col-sm-2 control-label">Cron<font color="red">*</font></label>
									<div class="col-sm-4"><input type="text" class="form-control" name="schedule_conf_CRON" placeholder="${I18n.system_please_input}Cron" maxlength="128" ></div>
								</div>
								<div class="schedule_conf schedule_conf_FIX_RATE" style="display: none" >
									<label for="lastname" class="col-sm-2 control-label">${I18n.schedule_type_fix_rate}<font color="red">*</font></label>
									<div class="col-sm-4"><input type="text" class="form-control" name="schedule_conf_FIX_RATE" placeholder="${I18n.system_please_input} （ Second ）" maxlength="10" onkeyup="this.value=this.value.replace(/\D/g,'')" onafterpaste="this.value=this.value.replace(/\D/g,'')" ></div>
								</div>
								<div class="schedule_conf schedule_conf_FIX_DELAY" style="display: none" >
									<label for="lastname" class="col-sm-2 control-label">${I18n.schedule_type_fix_delay}<font color="red">*</font></label>
									<div class="col-sm-4"><input type="text" class="form-control" name="schedule_conf_FIX_DELAY" placeholder="${I18n.system_please_input} （ Second ）" maxlength="10" onkeyup="this.value=this.value.replace(/\D/g,'')" onafterpaste="this.value=this.value.replace(/\D/g,'')" ></div>
								</div>
								<div class="schedule_conf schedule_conf_ONCE" style="display: none" >
									<label for="lastname" class="col-sm-2 control-label">${I18n.schedule_type_once}<font color="red">*</font></label>
									<div class="col-sm-4"><input type="text" class="form-control" name="schedule_conf_ONCE" placeholder="yyyy-MM-dd HH:mm:ss" maxlength="19" ></div>
								</div>
							</div>

							<br>
							<p style="margin: 0 0 10px;text-align: left;border-bottom: 1px solid #e5e5e5;color: gray;">${I18n.jobinfo_conf_job}</p>    <#-- 任务配置 -->

							<div class="form-group">
								<label for="firstname" class="col-sm-2 control-label">${I18n.jobinfo_field_gluetype}<font color="red">*</font></label>
								<div class="col-sm-4">
									<select class="form-control glueType" name="glueType" disabled >
										<#list GlueTypeEnum as item>
											<option value="${item}" >${item.desc}</option>
										</#list>
									</select>
								</div>
								<label for="firstname" class="col-sm-2 control-label">JobHandler<font color="red">*</font></label>
								<div class="col-sm-4"><input type="text" class="form-control" name="executorHandler" placeholder="${I18n.system_please_input}JobHandler" maxlength="100" ></div>
							</div>

							<div class="form-group">
								<label for="firstname" class="col-sm-2 control-label">${I18n.jobinfo_field_executorparam}<font color="black">*</font></label>
								<div class="col-sm-10">
									<textarea class="textarea form-control" name="executorParam" placeholder="${I18n.system_please_input}${I18n.jobinfo_field_executorparam}" maxlength="512" style="height: 63px; line-height: 1.2;"></textarea>
								</div>
							</div>

							<br>
							<p style="margin: 0 0 10px;text-align: left;border-bottom: 1px solid #e5e5e5;color: gray;">${I18n.jobinfo_conf_advanced}</p>    <#-- 高级配置 -->

							<div class="form-group">
								<label for="firstname" class="col-sm-2 control-label">${I18n.jobinfo_field_executorRouteStrategy}<font color="red">*</font></label>
								<div class="col-sm-4">
									<select class="form-control" name="executorRouteStrategy" >
										<#list ExecutorRouteStrategyEnum as item>
											<option value="${item}" >${item.title}</option>
										</#list>
									</select>
								</div>

								<label for="lastname" class="col-sm-2 control-label">${I18n.jobinfo_field_childJobId}<font color="black">*</font></label>
								<div class="col-sm-4"><input type="text" class="form-control" name="childJobId" placeholder="${I18n.jobinfo_field_childJobId_placeholder}" maxlength="100" ></div>
							</div>

							<div class="form-group">
								<label for="firstname" class="col-sm-2 control-label">${I18n.misfire_strategy}<font color="black">*</font></label>
								<div class="col-sm-4">
									<select class="form-control" name="misfireStrategy" >
										<#list MisfireStrategyEnum as item>
											<option value="${item}" <#if 'DO_NOTHING' == item >selected</#if> >${item.title}</option>
										</#list>
									</select>
								</div>

								<label for="firstname" class="col-sm-2 control-label">${I18n.jobinfo_field_executorBlockStrategy}<font color="red">*</font></label>
								<div class="col-sm-4">
									<select class="form-control" name="executorBlockStrategy" >
										<#list ExecutorBlockStrategyEnum as item>
											<option value="${item}" >${item.title}</option>
										</#list>
									</select>
								</div>
							</div>

							<div class="form-group">
								<label for="lastname" class="col-sm-2 control-label">${I18n.jobinfo_field_timeout}<font color="black">*</font></label>
								<div class="col-sm-4"><input type="text" class="form-control" name="executorTimeout" placeholder="${I18n.jobinfo_field_executorTimeout_placeholder}" maxlength="6" onkeyup="this.value=this.value.replace(/\D/g,'')" onafterpaste="this.value=this.value.replace(/\D/g,'')" ></div>
								<label for="lastname" class="col-sm-2 control-label">${I18n.jobinfo_field_executorFailRetryCount}<font color="black">*</font></label>
								<div class="col-sm-4"><input type="text" class="form-control" name="executorFailRetryCount" placeholder="${I18n.jobinfo_field_executorFailRetryCount_placeholder}" maxlength="4" onkeyup="this.value=this.value.replace(/\D/g,'')" onafterpaste="this.value=this.value.replace(/\D/g,'')" ></div>
							</div>

							<hr>
							<div class="form-group">
								<div class="col-sm-offset-3 col-sm-6">
									<button type="submit" class="btn btn-primary"  >${I18n.system_save}</button>
									<button type="button" class="btn btn-default" data-dismiss="modal">${I18n.system_cancel}</button>
									<input type="hidden" name="id" >
								</div>
							</div>

						</form>
					</div>
				</div>
			</div>
		</div>

		<#-- trigger -->
		<div class="modal fade" id="jobTriggerModal" tabindex="-1" role="dialog"  aria-hidden="true">
			<div class="modal-dialog ">
				<div class="modal-content">
					<div class="modal-header">
						<h4 class="modal-title" >${I18n.jobinfo_opt_run}</h4>
					</div>
					<div class="modal-body">
						<form class="form-horizontal form" role="form" >
							<div class="form-group">
								<label for="firstname" class="col-sm-2 control-label">${I18n.jobinfo_field_executorparam}<font color="black">*</font></label>
								<div class="col-sm-10">
									<textarea class="textarea form-control" name="executorParam" placeholder="${I18n.system_please_input}${I18n.jobinfo_field_executorparam}" maxlength="512" style="height: 63px; line-height: 1.2;"></textarea>
								</div>
							</div>
							<div class="form-group">
								<label for="firstname" class="col-sm-2 control-label">${I18n.jobgroup_field_registryList}<font color="black">*</font></label>
								<div class="col-sm-10">
									<textarea class="textarea form-control" name="addressList" placeholder="${I18n.jobinfo_opt_run_tips}" maxlength="512" style="height: 63px; line-height: 1.2;"></textarea>
								</div>
							</div>
							<div id="triggerExtraGroupsArea" style="display:none;">
								<div class="form-group">
									<label class="col-sm-2 control-label">同步执行器</label>
									<div class="col-sm-10">
										<select id="triggerExtraGroupSelect" multiple="multiple" style="width:100%">
										</select>
									</div>
								</div>
								<div id="triggerExtraAddressContainer"></div>
							</div>
							<hr>
							<div class="form-group">
								<div class="col-sm-offset-3 col-sm-6">
									<button type="button" class="btn btn-primary ok" >${I18n.system_save}</button>
									<button type="button" class="btn btn-default" data-dismiss="modal">${I18n.system_cancel}</button>
									<input type="hidden" name="id" >
								</div>
							</div>
						</form>
					</div>
				</div>
			</div>
		</div>

		<!-- 复制任务.模态框 -->
		<div class="modal fade" id="copyModal" tabindex="-1" role="dialog" aria-hidden="true">
			<div class="modal-dialog">
				<div class="modal-content">
					<div class="modal-header">
						<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
						<h4 class="modal-title">复制任务</h4>
					</div>
					<div class="modal-body">
						<div class="form-group">
							<label>选择目标执行器<font color="red">*</font></label>
							<select id="copyJobGroupSelect" multiple="multiple" style="width:100%">
								<#list JobGroupList as group>
									<option value="${group.id}">${group.title}</option>
								</#list>
							</select>
						</div>
					</div>
					<div class="modal-footer">
						<button type="button" class="btn btn-primary" id="copyConfirmBtn">确认复制</button>
						<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					</div>
				</div>
			</div>
		</div>

		<!-- 同步操作.模态框 -->
		<div class="modal fade" id="syncOpModal" tabindex="-1" role="dialog" aria-hidden="true">
			<div class="modal-dialog">
				<div class="modal-content">
					<div class="modal-header">
						<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
						<h4 class="modal-title" id="syncOpTitle">同步操作</h4>
					</div>
					<div class="modal-body">
						<div class="form-group">
							<label>以下执行器存在相同编码的任务，是否同步操作？</label>
							<select id="syncOpGroupSelect" multiple="multiple" style="width:100%">
							</select>
						</div>
					</div>
					<div class="modal-footer">
						<button type="button" class="btn btn-primary" id="syncOpConfirmBtn">确认</button>
						<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					</div>
				</div>
			</div>
		</div>

		<!-- 2-content end -->

	</section>
</div>

<!-- 3-script start -->
<@netCommon.commonScript />
<script src="${request.contextPath}/static/plugins/bootstrap-table/bootstrap-table.min.js"></script>
<script src="${request.contextPath}/static/plugins/bootstrap-table/locale/<#if I18n.admin_i18n?? && I18n.admin_i18n == 'en'>bootstrap-table-en-US.min.js<#else>bootstrap-table-zh-CN.min.js</#if>"></script>
<#-- admin table -->
<script src="${request.contextPath}/static/biz/common/admin.table.js"></script>
<#-- admin util -->
<script src="${request.contextPath}/static/biz/common/admin.util.js"></script>
<#-- moment -->
<script src="${request.contextPath}/static/adminlte/bower_components/moment/moment.min.js"></script>
<#-- cronGen -->
<script src="${request.contextPath}/static/plugins/cronGen/<#if I18n.admin_i18n?? && I18n.admin_i18n == 'en'>cronGen_en.js<#else>cronGen.js</#if>"></script>
<#-- select2 -->
<script src="${request.contextPath}/static/adminlte/bower_components/select2/select2.min.js"></script>
<script>
	// 自定义校验规则：仅允许英文字母或数字
	$.validator.addMethod("alphanumeric", function(value, element) {
		return this.optional(element) || /^[a-zA-Z0-9]+$/.test(value);
	}, "仅允许英文字母或数字");

	$(function() {

		// ---------------------- filter ----------------------

		/**
		 * jobGroup change
		 */
		$('#jobGroup').on('change', function(){
			//reload
			var jobGroup = $('#jobGroup').val();
			window.location.href = base_url + "/jobinfo?jobGroup=" + jobGroup;
		});

		// reset filter
		var jobGroup = '${jobGroup}';
		function resetFilter(){
			if (jobGroup > 0) {
				$("#jobGroup").val( jobGroup );
			}
		}
		resetFilter();

		// ---------------------- table ----------------------

		/**
		 * init table
		 */
		$.adminTable.initTable({
			table: '#data_list',
			url: base_url + "/jobinfo/pageList",
			queryParams: function (params) {
				var obj = {};
				obj.jobGroup = $('#jobGroup').val();
				obj.triggerStatus = $('#triggerStatus').val();
				obj.jobDesc = $('#jobDesc').val();
				obj.jobCode = $('#jobCode').val();
				obj.executorHandler = $('#executorHandler').val();
				obj.author = $('#author').val();
				obj.offset = params.offset;
				obj.pagesize = params.limit;
				return obj;
			},resetHandler : function() {
				// default
				$('#data_filter input[type="text"]').val('');
				$('#data_filter select').each(function() {
					$(this).prop('selectedIndex', 0);
				});

				// reset filter
				resetFilter();
			},
			columns:[
				{
					checkbox: true,
					field: 'state',
					width: '5',
					widthUnit: '%',
					align: 'center',
					valign: 'middle'
				},{
					title: I18n.jobinfo_field_id,
					field: 'id',
					width: '5',
					widthUnit: '%',
					align: 'left'
				}
				,{
					title: I18n.jobinfo_field_jobdesc,
					field: 'jobDesc',
					width: '25',
					widthUnit: '%',
					align: 'left',
					formatter: function(value, row, index) {
						if (value.length > 15) {
							return '<span title="' + value + '">' + value.substr(0, 15) + '...</span>';
						} else {
							return value;
						}
					}
				},{
					title: '任务编码',
					field: 'jobCode',
					width: '10',
					widthUnit: '%',
					align: 'left'
				},{
					title: '来源',
					field: 'source',
					width: '5',
					widthUnit: '%',
					align: 'center',
					formatter: function(value, row, index) {
						if (value == 1) {
							return '<small class="label label-info">API</small>';
						} else {
							return '<small class="label label-default">后台</small>';
						}
					}
				},{
					title: I18n.jobinfo_field_remark,
					field: 'remark',
					width: '20',
					widthUnit: '%',
					align: 'left'
				},{
					title: I18n.schedule_type,
					field: 'scheduleType',
					width: '15',
					widthUnit: '%',
					formatter: function(value, row, index) {
						if (row.scheduleConf) {
							return row.scheduleType + '：'+ row.scheduleConf;
						} else {
							return row.scheduleType;
						}
					}
				},{
					title: I18n.jobinfo_field_gluetype,
					field: 'glueType',
					width: '25',
					widthUnit: '%',
					formatter: function(value, row, index) {
						// find glueType title
						let glueTypeTitle = '';
						$("#addModal .form select[name=glueType] option").each(function () {
							if (row.glueType == $(this).val()) {
								glueTypeTitle = $(this).text();
							}
						});

						// append handler
						if (row.executorHandler) {
							return glueTypeTitle +"：" + row.executorHandler;
						} else {
							return glueTypeTitle;
						}
					}
				},{
					title: I18n.system_status,
					field: 'triggerStatus',
					width: '10',
					widthUnit: '%',
					formatter: function(value, row, index) {
						// 调度状态：0-停止，1-运行
						if (1 == value) {
							return '<small class="label label-success" >RUNNING</small>';
						} else {
							return '<small class="label label-default" >STOP</small>';
						}
						return value;
					}
				},{
					title: I18n.jobinfo_field_author,
					field: 'author',
					width: '10',
					widthUnit: '%'
				}
			]
		});

		// ---------------------- delete ----------------------

		/**
		 * showSyncOpModal: 同步操作弹窗（删除/启动/停止共用）
		 * @param row         当前选中行数据
		 * @param opTitle     操作标题（如 "删除"、"启动"、"停止"）
		 * @param opUrl       操作请求地址（如 "/jobinfo/delete"）
		 * @param successMsg  成功提示
		 * @param failMsg     失败提示
		 */
		function showSyncOpModal(row, opTitle, opUrl, successMsg, failMsg) {
			var selectIds = [row.id];

			// 执行实际操作的函数
			function doOp(extraGroups) {
				var postData = { "ids": selectIds };
				if (extraGroups && extraGroups.length > 0) {
					postData["extraGroups"] = extraGroups;
				}
				$.ajax({
					type: 'POST',
					url: base_url + opUrl,
					data: postData,
					dataType: "json",
					success: function(data) {
						if (data.code === 200) {
							layer.msg(successMsg);
							$('#data_filter .searchBtn').click();
						} else {
							layer.msg(data.msg || failMsg);
						}
					},
					error: function(xhr, status, error) {
						console.log("Error: " + error);
						layer.open({ icon: '2', content: failMsg });
					}
				});
			}

			// 若无 jobCode，直接走原有逻辑
			if (!row.jobCode) {
				layer.confirm(I18n.system_ok + opTitle + '?', {
					icon: 3, title: I18n.system_tips,
					btn: [I18n.system_ok, I18n.system_cancel]
				}, function(index) {
					layer.close(index);
					doOp(null);
				});
				return;
			}

			// 查询是否有其他执行器拥有相同 jobCode
			$.get(base_url + "/jobinfo/groupsWithCode",
				{ jobCode: row.jobCode, excludeGroup: row.jobGroup },
				function(data) {
					if (data.code == 200 && data.data && data.data.length > 0) {
						// 有其他执行器 → 弹出 syncOpModal
						$('#syncOpTitle').text('同步' + opTitle);
						var $select = $('#syncOpGroupSelect');
						$select.empty();
						var allIds = [];
						data.data.forEach(function(gid) {
							// 从 JobGroupList 获取执行器名称
							var title = '';
							<#list JobGroupList as group>
							if (gid == ${group.id}) { title = '${group.title}'; }
							</#list>
							$select.append('<option value="'+ gid +'">'+ (title || ('执行器' + gid)) +'</option>');
							allIds.push(gid);
						});
						$select.val(allIds);
						$select.select2({ placeholder: "选择要同步操作的执行器", width: '100%' });

						// 绑定确认按钮（先解绑旧事件）
						$('#syncOpConfirmBtn').off('click').on('click', function() {
							var extraGroups = $select.val();
							$('#syncOpModal').modal('hide');
							doOp(extraGroups);
						});

						$('#syncOpModal').modal('show');
					} else {
						// 无其他执行器 → 直接 confirm
						layer.confirm(I18n.system_ok + opTitle + '?', {
							icon: 3, title: I18n.system_tips,
							btn: [I18n.system_ok, I18n.system_cancel]
						}, function(index) {
							layer.close(index);
							doOp(null);
						});
					}
				}
			);
		}

		/**
		 * batchOp: 批量操作（启动/停止多选，支持同步到其他执行器）
		 */
		function batchOp(rows, opTitle, opUrl) {
			// 收集所有选中行的 jobCode，查找涉及的其他执行器
			var allExtraGroups = {};  // groupId -> title
			var queryDone = 0;
			var queryTotal = 0;
			var rowsWithCode = [];

			rows.forEach(function(row) {
				if (row.jobCode) {
					rowsWithCode.push(row);
				}
			});
			queryTotal = rowsWithCode.length;

			function onQueriesDone() {
				var groupIds = Object.keys(allExtraGroups);
				if (groupIds.length > 0) {
					// 有其他执行器 → 弹出 syncOpModal
					$('#syncOpTitle').text('批量' + opTitle + '（' + rows.length + ' 条任务）');
					var $select = $('#syncOpGroupSelect');
					$select.empty();
					var allIds = [];
					groupIds.forEach(function(gid) {
						$select.append('<option value="'+ gid +'">'+ allExtraGroups[gid] +'</option>');
						allIds.push(gid);
					});
					$select.val(allIds);
					$select.select2({ placeholder: "选择要同步操作的执行器", width: '100%' });

					$('#syncOpConfirmBtn').off('click').on('click', function() {
						var extraGroups = $select.val();
						$('#syncOpModal').modal('hide');
						doBatchOp(rows, opTitle, opUrl, extraGroups);
					});
					$('#syncOpModal').modal('show');
				} else {
					// 无其他执行器 → 直接确认
					layer.confirm(I18n.system_ok + opTitle + ' ' + rows.length + ' 条任务?', {
						icon: 3, title: I18n.system_tips,
						btn: [I18n.system_ok, I18n.system_cancel]
					}, function(index) {
						layer.close(index);
						doBatchOp(rows, opTitle, opUrl, null);
					});
				}
			}

			if (queryTotal === 0) {
				onQueriesDone();
			} else {
				rowsWithCode.forEach(function(row) {
					$.get(base_url + "/jobinfo/groupsWithCode",
						{ jobCode: row.jobCode, excludeGroup: row.jobGroup },
						function(data) {
							if (data.code == 200 && data.data) {
								data.data.forEach(function(gid) {
									if (!allExtraGroups[gid]) {
										var title = '';
										<#list JobGroupList as group>
										if (gid == ${group.id}) { title = '${group.title}'; }
										</#list>
										allExtraGroups[gid] = title || ('执行器' + gid);
									}
								});
							}
							queryDone++;
							if (queryDone === queryTotal) { onQueriesDone(); }
						}
					).fail(function() {
						queryDone++;
						if (queryDone === queryTotal) { onQueriesDone(); }
					});
				});
			}
		}

		function doBatchOp(rows, opTitle, opUrl, extraGroups) {
			var successCount = 0;
			var failCount = 0;
			var doneCount = 0;
			var total = rows.length;
			var loadIndex = layer.load(1);
			for (var i = 0; i < total; i++) {
				(function(row) {
					var postData = { "ids": [row.id] };
					if (extraGroups && extraGroups.length > 0) {
						postData["extraGroups"] = extraGroups;
					}
					$.ajax({
						type: 'POST',
						url: base_url + opUrl,
						data: postData,
						dataType: "json",
						success: function(data) {
							if (data.code === 200) { successCount++; } else { failCount++; }
						},
						error: function() { failCount++; },
						complete: function() {
							doneCount++;
							if (doneCount === total) {
								layer.close(loadIndex);
								layer.msg(opTitle + '完成：成功 ' + successCount + ' 条，失败 ' + failCount + ' 条');
								$('#data_filter .searchBtn').click();
							}
						}
					});
				})(rows[i]);
			}
		}

		/**
		 * delete
		 */
		$("#data_operation").on('click', '.delete',function() {
			var rows = $.adminTable.table.bootstrapTable('getSelections');
			if (rows.length !== 1) {
				layer.msg(I18n.system_please_choose + I18n.system_one + I18n.system_data);
				return;
			}
			showSyncOpModal(rows[0], I18n.system_opt_del, '/jobinfo/delete',
				I18n.system_opt_del + I18n.system_success,
				I18n.system_opt_del + I18n.system_fail);
		});

		// ---------------------- start  ----------------------

		/**
		 * start (支持多选)
		 */
		$("#data_operation").on('click', '.job_resume',function() {
			var rows = $.adminTable.table.bootstrapTable('getSelections');
			if (rows.length < 1) {
				layer.msg(I18n.system_please_choose + I18n.system_data);
				return;
			}
			if (rows.length === 1) {
				showSyncOpModal(rows[0], I18n.jobinfo_opt_start, '/jobinfo/start',
					I18n.jobinfo_opt_start + I18n.system_success,
					I18n.jobinfo_opt_start + I18n.system_fail);
			} else {
				batchOp(rows, I18n.jobinfo_opt_start, '/jobinfo/start');
			}
		});

		// ---------------------- stop ----------------------

		/**
		 * stop (支持多选)
		 */
		$("#data_operation").on('click', '.job_pause',function() {
			var rows = $.adminTable.table.bootstrapTable('getSelections');
			if (rows.length < 1) {
				layer.msg(I18n.system_please_choose + I18n.system_data);
				return;
			}
			if (rows.length === 1) {
				showSyncOpModal(rows[0], I18n.jobinfo_opt_stop, '/jobinfo/stop',
					I18n.jobinfo_opt_stop + I18n.system_success,
					I18n.jobinfo_opt_stop + I18n.system_fail);
			} else {
				batchOp(rows, I18n.jobinfo_opt_stop, '/jobinfo/stop');
			}
		});

		// ---------------------- trigger ----------------------

		/**
		 * job trigger
		 */
		// groupId -> title mapping for trigger modal
		var triggerGroupMap = {};
		<#list JobGroupList as group>
		triggerGroupMap[${group.id}] = '${group.title}';
		</#list>

		$("#data_operation").on('click', '.job_trigger',function() {
			// get select rows
			var rows = $.adminTable.table.bootstrapTable('getSelections');

			// find select row
			if (rows.length !== 1) {
				layer.msg(I18n.system_please_choose + I18n.system_one + I18n.system_data);
				return;
			}
			var row = rows[0];

			// fill modal
			$("#jobTriggerModal .form input[name='id']").val( row.id );
			$("#jobTriggerModal .form textarea[name='executorParam']").val( row.executorParam );

			// init extra groups area
			var $extraArea = $('#triggerExtraGroupsArea');
			var $extraSelect = $('#triggerExtraGroupSelect');
			var $extraContainer = $('#triggerExtraAddressContainer');
			$extraSelect.empty();
			$extraContainer.empty();
			$extraArea.hide();

			if (row.jobCode) {
				$.get(base_url + "/jobinfo/groupsWithCode",
					{ jobCode: row.jobCode, excludeGroup: row.jobGroup },
					function(data) {
						if (data.code == 200 && data.data && data.data.length > 0) {
							var allIds = [];
							data.data.forEach(function(gid) {
								var title = triggerGroupMap[gid] || ('执行器' + gid);
								$extraSelect.append('<option value="'+ gid +'">'+ title +'</option>');
								allIds.push(String(gid));
							});
							$extraSelect.val(allIds);
							$extraSelect.select2({ placeholder: "选择要同步触发的执行器", width: '100%' });
							$extraArea.show();

							// generate address inputs for default selected
							renderTriggerExtraAddressInputs();
						}
					}
				);
			}

			$('#jobTriggerModal').modal({backdrop: false, keyboard: false}).modal('show');
		});

		// render address inputs based on selected extra groups
		function renderTriggerExtraAddressInputs() {
			var $extraContainer = $('#triggerExtraAddressContainer');
			var selectedIds = $('#triggerExtraGroupSelect').val() || [];

			// preserve existing values
			var existingValues = {};
			$extraContainer.find('textarea[data-group-id]').each(function() {
				existingValues[$(this).attr('data-group-id')] = $(this).val();
			});

			$extraContainer.empty();
			selectedIds.forEach(function(gid) {
				var title = triggerGroupMap[gid] || ('执行器' + gid);
				var savedVal = existingValues[gid] || '';
				var html = '<div class="form-group" data-extra-group="'+ gid +'">'
					+ '<label class="col-sm-2 control-label">'+ title +'</label>'
					+ '<div class="col-sm-10">'
					+ '<textarea class="textarea form-control" data-group-id="'+ gid +'" placeholder="执行地址（为空则使用默认地址）" maxlength="512" style="height: 50px; line-height: 1.2;">'+ savedVal +'</textarea>'
					+ '</div></div>';
				$extraContainer.append(html);
			});
		}

		// listen select2 change
		$(document).on('change', '#triggerExtraGroupSelect', function() {
			renderTriggerExtraAddressInputs();
		});

		$("#jobTriggerModal .ok").on('click',function() {
			var postData = {
				"id" : $("#jobTriggerModal .form input[name='id']").val(),
				"executorParam" : $("#jobTriggerModal .textarea[name='executorParam']").val(),
				"addressList" : $("#jobTriggerModal .textarea[name='addressList']").val()
			};

			// collect extra groups and their addressList
			var selectedIds = $('#triggerExtraGroupSelect').val() || [];
			if (selectedIds.length > 0) {
				var groups = [];
				var addrs = [];
				selectedIds.forEach(function(gid) {
					groups.push(gid);
					var addr = $('#triggerExtraAddressContainer textarea[data-group-id="'+ gid +'"]').val() || '';
					addrs.push(addr);
				});
				postData["extraGroups"] = groups;
				postData["extraAddressList"] = addrs;
			}

			$.ajax({
				type : 'POST',
				url : base_url + "/jobinfo/trigger",
				data : postData,
				traditional : true,
				dataType : "json",
				success : function(data){
					if (data.code == 200 && data.data && data.data.length > 0) {
						$('#jobTriggerModal').modal('hide');
						var results = data.data;
						// single executor: simple message
						if (results.length === 1) {
							if (results[0].success) {
								layer.msg(I18n.jobinfo_opt_run + I18n.system_success);
							} else {
								layer.msg(results[0].groupTitle + '：' + results[0].msg);
							}
						} else {
							// multiple executors: show detail popup
							var html = '<div style="text-align:left;padding:10px;">';
							for (var i = 0; i < results.length; i++) {
								var r = results[i];
								var icon = r.success
									? '<span class="label label-success">成功</span>'
									: '<span class="label label-danger">失败</span>';
								html += '<p>' + icon + ' <b>' + r.groupTitle + '</b>';
								if (!r.success) {
									html += '：' + r.msg;
								}
								html += '</p>';
							}
							html += '<p style="color:gray;margin-top:10px;border-top:1px solid #eee;padding-top:8px;">以任务执行日志结果为准</p>';
							html += '</div>';
							layer.open({
								title: I18n.jobinfo_opt_run + ' - 执行结果',
								btn: [I18n.system_ok],
								area: ['450px'],
								content: html
							});
						}
					} else {
						layer.msg( data.msg || I18n.jobinfo_opt_run + I18n.system_fail );
					}
				}
			});
		});
		$("#jobTriggerModal").on('hide.bs.modal', function () {
			$("#jobTriggerModal .form")[0].reset();
			$('#triggerExtraGroupSelect').empty();
			$('#triggerExtraAddressContainer').empty();
			$('#triggerExtraGroupsArea').hide();
		});

		// ---------------------- registryinfo ----------------------

		/**
		 * job registryinfo
		 */
		$("#data_operation").on('click', '.job_registryinfo',function() {
			// get select rows
			var rows = $.adminTable.table.bootstrapTable('getSelections');

			// find select row
			if (rows.length !== 1) {
				layer.msg(I18n.system_please_choose + I18n.system_one + I18n.system_data);
				return;
			}
			var row = rows[0];

			// invoke
			$.ajax({
				type : 'POST',
				url : base_url + "/jobgroup/loadById",
				data : {
					"id" : row.jobGroup
				},
				dataType : "json",
				success : function(data){

					var html = '<div>';
					if (data.code == 200 && data.data.registryList) {
						for (var index in data.data.registryList) {
							html += (parseInt(index)+1) + '. <span class="badge bg-green" >' + data.data.registryList[index] + '</span><br>';
						}
					}
					html += '</div>';

					layer.open({
						title: I18n.jobinfo_opt_registryinfo ,
						btn: [ I18n.system_ok ],
						content: html
					});

				}
			});

		});

		// ---------------------- job_log ----------------------

		/**
		 * job_log
		 */
		$("#data_operation").on('click', '.job_log',function() {
			// get select rows
			var rows = $.adminTable.table.bootstrapTable('getSelections');

			// find select row
			if (rows.length !== 1) {
				layer.msg(I18n.system_please_choose + I18n.system_one + I18n.system_data);
				return;
			}
			var row = rows[0];

			// open tab
			let url = base_url +'/joblog?jobId='+ row.id;
			openTab(url, I18n.joblog_name, false);
		});

		// ---------------------- glue_ide ----------------------

		/**
		 * glue_ide
		 */
		$("#data_operation").on('click', '.glue_ide',function() {
			// get select rows
			var rows = $.adminTable.table.bootstrapTable('getSelections');

			// find select row
			if (rows.length !== 1) {
				layer.msg(I18n.system_please_choose + I18n.system_one + I18n.system_data);
				return;
			}
			var row = rows[0];

			// valid
			if ('BEAN' === row.glueType) {
				layer.msg(I18n.jobinfo_glue_gluetype_unvalid);
				return;
			}

			// open tab
			let url = base_url +'/jobcode?jobId='+ row.id;
			window.open(url);
			//openTab(url, 'GLUE IDE', false);
		});

		// ---------------------- job_next_time ----------------------

		/**
		 * job registryinfo
		 */
		$("#data_operation").on('click', '.job_next_time',function() {
			// get select rows
			var rows = $.adminTable.table.bootstrapTable('getSelections');

			// find select row
			if (rows.length !== 1) {
				layer.msg(I18n.system_please_choose + I18n.system_one + I18n.system_data);
				return;
			}
			var row = rows[0];

			// invoke
			$.ajax({
				type : 'POST',
				url : base_url + "/jobinfo/nextTriggerTime",
				data : {
					"scheduleType" : row.scheduleType,
					"scheduleConf" : row.scheduleConf
				},
				dataType : "json",
				success : function(data){

					if (data.code != 200) {
						layer.open({
							title: I18n.jobinfo_opt_next_time ,
							btn: [ I18n.system_ok ],
							content: data.msg
						});
					} else {
						var html = '<center>';
						if (data.code == 200 && data.data) {
							for (var index in data.data) {
								html += '<span>' + data.data[index] + '</span><br>';
							}
						}
						html += '</center>';

						layer.open({
							title: I18n.jobinfo_opt_next_time ,
							btn: [ I18n.system_ok ],
							content: html
						});
					}

				}
			});

		});

		// ---------------------- add ----------------------

		/**
		 * add
		 */
		$.adminTable.initAdd( {
			url: base_url + "/jobinfo/insert",
			rules : {
				jobDesc : {
					required : true,
					maxlength: 50
				},
				jobCode : {
					required : true,
					maxlength: 64,
					alphanumeric: true
				},
				author : {
					required : true
				}
			},
			messages : {
				jobDesc : {
					required : I18n.system_please_input + I18n.jobinfo_field_jobdesc
				},
				jobCode : {
					required : '请输入任务编码',
					alphanumeric: '任务编码仅允许英文字母或数字'
				},
				author : {
					required : I18n.system_please_input + I18n.jobinfo_field_author
				}
			},
			writeFormData: function() {
				// init-cronGen
				$("#addModal .form input[name='schedule_conf_CRON']").show().siblings().remove();
				$("#addModal .form input[name='schedule_conf_CRON']").cronGen({});

				// 》init scheduleType
				$("#addModal .form select[name=scheduleType]").change();

				// 》init glueType
				$("#addModal .form select[name=glueType]").change();

				// init extraGroups Select2
				var currentGroup = $("#addModal .form select[name='jobGroup']").val();
				var $extra = $("#addModal .form select[name='extraGroups']");
				$extra.val(null);
				$extra.find('option').prop('disabled', false);
				$extra.find('option[value="'+ currentGroup +'"]').prop('disabled', true).prop('selected', false);
				$extra.select2({ placeholder: "可选：同步新增到其他执行器", width: '100%' });
			},
			readFormData: function() {

				// process executorTimeout+executorFailRetryCount
				var executorTimeout = $("#addModal .form input[name='executorTimeout']").val();
				if(!/^\d+$/.test(executorTimeout)) {
					executorTimeout = 0;
				}
				$("#addModal .form input[name='executorTimeout']").val(executorTimeout);
				var executorFailRetryCount = $("#addModal .form input[name='executorFailRetryCount']").val();
				if(!/^\d+$/.test(executorFailRetryCount)) {
					executorFailRetryCount = 0;
				}
				$("#addModal .form input[name='executorFailRetryCount']").val(executorFailRetryCount);

				// process schedule_conf
				var scheduleType = $("#addModal .form select[name='scheduleType']").val();
				var scheduleConf;
				if (scheduleType == 'CRON') {
					scheduleConf = $("#addModal .form input[name='cronGen_display']").val();
				} else if (scheduleType == 'FIX_RATE') {
					scheduleConf = $("#addModal .form input[name='schedule_conf_FIX_RATE']").val();
				} else if (scheduleType == 'FIX_DELAY') {
					scheduleConf = $("#addModal .form input[name='schedule_conf_FIX_DELAY']").val();
				} else if (scheduleType == 'ONCE') {
					scheduleConf = $("#addModal .form input[name='schedule_conf_ONCE']").val();
				}
				$("#addModal .form input[name='scheduleConf']").val( scheduleConf );

				return $("#addModal .form").serialize();
			}
		});

		// generateJobCode: 根据任务描述自动生成任务编码
		$(".generateJobCode").click(function(){
			var $form = $(this).closest('form');
			var jobDesc = $form.find("input[name='jobDesc']").val();
			if (!jobDesc) {
				layer.msg("请先输入任务描述");
				return;
			}
			var $btn = $(this);
			$btn.prop('disabled', true);
			$.get(base_url + "/jobinfo/generateCode", { jobDesc: jobDesc }, function(data) {
				$btn.prop('disabled', false);
				if (data.code == 200) {
					$form.find("input[name='jobCode']").val(data.data);
				} else {
					layer.msg(data.msg || "生成失败");
				}
			}).fail(function() {
				$btn.prop('disabled', false);
				layer.msg("请求失败");
			});
		});

		// addModal jobGroup change: update extraGroups disabled option
		$("#addModal .form select[name='jobGroup']").change(function(){
			var currentGroup = $(this).val();
			var $extra = $("#addModal .form select[name='extraGroups']");
			$extra.val(null);
			$extra.find('option').prop('disabled', false);
			$extra.find('option[value="'+ currentGroup +'"]').prop('disabled', true);
			$extra.trigger('change');
		});

		// scheduleType change
		$(".scheduleType").change(function(){
			var scheduleType = $(this).val();
			$(this).parents("form").find(".schedule_conf").hide();
			$(this).parents("form").find(".schedule_conf_" + scheduleType).show();

		});

		// glueType change
		$(".glueType").change(function(){
			// executorHandler
			var $executorHandler = $(this).parents("form").find("input[name='executorHandler']");
			var glueType = $(this).val();
			if ('BEAN' != glueType) {
				$executorHandler.val("");
				$executorHandler.attr("readonly","readonly");
			} else {
				$executorHandler.removeAttr("readonly");
			}
		});

		// glueType init source
		$("#addModal .glueType").change(function(){
			// glueSource
			var glueType = $(this).val();
			if ('GLUE_GROOVY'==glueType){
				$("#addModal .form textarea[name='glueSource']").val( $("#addModal .form .glueSource_java").val() );
			} else if ('GLUE_SHELL'==glueType){
				$("#addModal .form textarea[name='glueSource']").val( $("#addModal .form .glueSource_shell").val() );
			} else if ('GLUE_PYTHON'==glueType){
				$("#addModal .form textarea[name='glueSource']").val( $("#addModal .form .glueSource_python").val() );
			} else if ('GLUE_PYTHON2'==glueType){
				$("#addModal .form textarea[name='glueSource']").val( $("#addModal .form .glueSource_python2").val() );
			} else if ('GLUE_PHP'==glueType){
				$("#addModal .form textarea[name='glueSource']").val( $("#addModal .form .glueSource_php").val() );
			} else if ('GLUE_NODEJS'==glueType){
				$("#addModal .form textarea[name='glueSource']").val( $("#addModal .form .glueSource_nodejs").val() );
			} else if ('GLUE_POWERSHELL'==glueType){
				$("#addModal .form textarea[name='glueSource']").val( $("#addModal .form .glueSource_powershell").val() );
			} else {
				$("#addModal .form textarea[name='glueSource']").val("");
			}
		});

		// ---------------------- update ----------------------

		/**
		 * init update
		 */
		$.adminTable.initUpdate( {
			url: base_url + "/jobinfo/update",
			rules : {
				jobDesc : {
					required : true,
					maxlength: 50
				},
				jobCode : {
					required : true,
					maxlength: 64,
					alphanumeric: true
				},
				author : {
					required : true
				}
			},
			messages : {
				jobDesc : {
					required : I18n.system_please_input + I18n.jobinfo_field_jobdesc
				},
				jobCode : {
					required : '请输入任务编码',
					alphanumeric: '任务编码仅允许英文字母或数字'
				},
				author : {
					required : I18n.system_please_input + I18n.jobinfo_field_author
				}
			},
			writeFormData: function(row) {

				// fill base
				$("#updateModal .form input[name='id']").val( row.id );
				$('#updateModal .form select[name=jobGroup] option[value='+ row.jobGroup +']').prop('selected', true);
				$("#updateModal .form input[name='jobDesc']").val( row.jobDesc );
				$("#updateModal .form input[name='jobCode']").val( row.jobCode );
				$("#updateModal .form input[name='author']").val( row.author );
				$("#updateModal .form input[name='alarmEmail']").val( row.alarmEmail );
				$("#updateModal .form input[name='remark']").val( row.remark );

				// fill trigger
				$('#updateModal .form select[name=scheduleType] option[value='+ row.scheduleType +']').prop('selected', true);
				$("#updateModal .form input[name='scheduleConf']").val( row.scheduleConf );
				if (row.scheduleType == 'CRON') {
					$("#updateModal .form input[name='schedule_conf_CRON']").val( row.scheduleConf );
				} else if (row.scheduleType == 'FIX_RATE') {
					$("#updateModal .form input[name='schedule_conf_FIX_RATE']").val( row.scheduleConf );
				} else if (row.scheduleType == 'FIX_DELAY') {
					$("#updateModal .form input[name='schedule_conf_FIX_DELAY']").val( row.scheduleConf );
				} else if (row.scheduleType == 'ONCE') {
					$("#updateModal .form input[name='schedule_conf_ONCE']").val( row.scheduleConf );
				}

				// 》init scheduleType
				$("#updateModal .form select[name=scheduleType]").change();

				// fill job
				$('#updateModal .form select[name=glueType] option[value='+ row.glueType +']').prop('selected', true);
				$("#updateModal .form input[name='executorHandler']").val( row.executorHandler );
				$("#updateModal .form textarea[name='executorParam']").val( row.executorParam );

				// 》init glueType
				$("#updateModal .form select[name=glueType]").change();

				// 》init-cronGen
				$("#updateModal .form input[name='schedule_conf_CRON']").show().siblings().remove();
				$("#updateModal .form input[name='schedule_conf_CRON']").cronGen({});

				// fill advanced
				$('#updateModal .form select[name=executorRouteStrategy] option[value='+ row.executorRouteStrategy +']').prop('selected', true);
				$("#updateModal .form input[name='childJobId']").val( row.childJobId );
				$('#updateModal .form select[name=misfireStrategy] option[value='+ row.misfireStrategy +']').prop('selected', true);
				$('#updateModal .form select[name=executorBlockStrategy] option[value='+ row.executorBlockStrategy +']').prop('selected', true);
				$("#updateModal .form input[name='executorTimeout']").val( row.executorTimeout );
				$("#updateModal .form input[name='executorFailRetryCount']").val( row.executorFailRetryCount );

				// init extraGroups Select2 for update
				var $extra = $("#updateModal .form select[name='extraGroups']");
				$extra.empty();
				if (row.jobCode) {
					$.get(base_url + "/jobinfo/groupsWithCode",
						{ jobCode: row.jobCode, excludeGroup: row.jobGroup },
						function(data) {
							if (data.code == 200 && data.data) {
								var allIds = [];
								data.data.forEach(function(gid) {
									var title = $("#updateModal .form select[name='jobGroup'] option[value='"+ gid +"']").text();
									$extra.append('<option value="'+ gid +'">'+ title +'</option>');
									allIds.push(gid);
								});
								$extra.val(allIds);
							}
							$extra.select2({ placeholder: "可选：同步更新到其他执行器", width: '100%' });
						}
					);
				} else {
					$extra.select2({ placeholder: "可选：同步更新到其他执行器", width: '100%' });
				}

			},
			readFormData: function() {

				// process executorTimeout + executorFailRetryCount
				var executorTimeout = $("#updateModal .form input[name='executorTimeout']").val();
				if(!/^\d+$/.test(executorTimeout)) {
					executorTimeout = 0;
				}
				$("#updateModal .form input[name='executorTimeout']").val(executorTimeout);
				var executorFailRetryCount = $("#updateModal .form input[name='executorFailRetryCount']").val();
				if(!/^\d+$/.test(executorFailRetryCount)) {
					executorFailRetryCount = 0;
				}
				$("#updateModal .form input[name='executorFailRetryCount']").val(executorFailRetryCount);


				// process schedule_conf
				var scheduleType = $("#updateModal .form select[name='scheduleType']").val();
				var scheduleConf;
				if (scheduleType == 'CRON') {
					scheduleConf = $("#updateModal .form input[name='cronGen_display']").val();
				} else if (scheduleType == 'FIX_RATE') {
					scheduleConf = $("#updateModal .form input[name='schedule_conf_FIX_RATE']").val();
				} else if (scheduleType == 'FIX_DELAY') {
					scheduleConf = $("#updateModal .form input[name='schedule_conf_FIX_DELAY']").val();
				} else if (scheduleType == 'ONCE') {
					scheduleConf = $("#updateModal .form input[name='schedule_conf_ONCE']").val();
				}
				$("#updateModal .form input[name='scheduleConf']").val( scheduleConf );

				return $("#updateModal .form").serialize();
			}
		});

		// ---------------------- job_copy ----------------------

		/**
		 * job_copy：多选执行器批量复制
		 */
		$("#data_operation").on('click', '.job_copy', function() {
			// get select rows
			var rows = $.adminTable.table.bootstrapTable('getSelections');

			// find select row
			if (rows.length !== 1) {
				layer.msg(I18n.system_please_choose + I18n.system_one + I18n.system_data);
				return;
			}
			var row = rows[0];

			// 初始化 Select2 多选，默认为空
			$('#copyJobGroupSelect').val(null).trigger('change');
			$('#copyJobGroupSelect').select2({
				placeholder: "请选择目标执行器",
				allowClear: true
			});

			// 存储行数据到 modal
			$('#copyModal').data('row', row);
			$('#copyModal').modal('show');
		});

		/**
		 * 构建复制任务的表单数据
		 */
		function buildCopyFormData(row, groupId) {
			var formData = {
				jobGroup: groupId,
				jobCode: row.jobCode,
				jobDesc: row.jobDesc,
				author: row.author,
				alarmEmail: row.alarmEmail,
				remark: row.remark,
				scheduleType: row.scheduleType,
				scheduleConf: row.scheduleConf,
				glueType: row.glueType,
				executorHandler: row.executorHandler,
				executorParam: row.executorParam,
				executorRouteStrategy: row.executorRouteStrategy,
				childJobId: row.childJobId,
				misfireStrategy: row.misfireStrategy,
				executorBlockStrategy: row.executorBlockStrategy,
				executorTimeout: row.executorTimeout || 0,
				executorFailRetryCount: row.executorFailRetryCount || 0,
				glueRemark: 'GLUE代码初始化',
				glueSource: ''
			};
			return formData;
		}

		/**
		 * 确认复制
		 */
		$('#copyConfirmBtn').on('click', function() {
			var row = $('#copyModal').data('row');
			var selectedGroups = $('#copyJobGroupSelect').val();
			if (!selectedGroups || selectedGroups.length === 0) {
				layer.msg("请选择至少一个执行器");
				return;
			}

			var successCount = 0, skipCount = 0, failCount = 0, totalCount = selectedGroups.length;
			var $btn = $(this);
			$btn.prop('disabled', true);

			function showCopyResult() {
				var msg = "复制完成：成功" + successCount + "个";
				if (skipCount > 0) {
					msg += "，跳过" + skipCount + "个（编码已存在）";
				}
				if (failCount > 0) {
					msg += "，失败" + failCount + "个";
				}
				layer.msg(msg);
				$btn.prop('disabled', false);
				$('#copyModal').modal('hide');
				$.adminTable.table.bootstrapTable('refresh');
			}

			selectedGroups.forEach(function(groupId) {
				var formData = buildCopyFormData(row, groupId);
				$.post(base_url + "/jobinfo/insert", formData, function(data) {
					if (data.code == 200) {
						successCount++;
					} else if (data.msg && data.msg.indexOf('已存在') > -1) {
						skipCount++;
					} else {
						failCount++;
					}
					if (successCount + skipCount + failCount === totalCount) {
						showCopyResult();
					}
				}).fail(function() {
					failCount++;
					if (successCount + skipCount + failCount === totalCount) {
						showCopyResult();
					}
				});
			});
		});

	});

</script>
<!-- 3-script end -->

</body>
</html>