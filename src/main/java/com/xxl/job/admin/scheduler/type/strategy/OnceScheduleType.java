package com.xxl.job.admin.scheduler.type.strategy;

import com.xxl.job.admin.model.XxlJobInfo;
import com.xxl.job.admin.scheduler.type.ScheduleType;
import com.xxl.tool.core.DateTool;

import java.util.Date;

public class OnceScheduleType extends ScheduleType {

    @Override
    public Date generateNextTriggerTime(XxlJobInfo jobInfo, Date fromTime) throws Exception {
        Date targetTime = DateTool.parseDateTime(jobInfo.getScheduleConf());
        if (targetTime != null && targetTime.after(fromTime)) {
            return targetTime;
        }
        return null;
    }

}
