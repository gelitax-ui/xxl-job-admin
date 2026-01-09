package com.xxl.job.admin.service.impl;

import com.xxl.job.admin.mapper.SmsConfigMapper;
import com.xxl.job.admin.mapper.XxlJobInfoMapper;
import com.xxl.job.admin.mapper.XxlJobLogMapper;
import com.xxl.job.admin.model.XxlJobInfo;
import com.xxl.job.admin.model.XxlJobLog;
import com.xxl.job.admin.service.ListenService;
import com.xxl.job.admin.service.SmsSendingService;
import com.xxl.job.admin.util.SmsEnum;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@Transactional(rollbackFor = Exception.class)
public class ListenServiceImpl implements ListenService {

    @Autowired
    XxlJobLogMapper xxlJobLogMapper;

    @Autowired
    XxlJobInfoMapper xxlJobInfoMapper;

    @Autowired
    SmsConfigMapper smsConfigMapper;

    @Autowired
    SmsSendingService smsSendingService;

    @Override
    public String listenTask(String phone) {
        StringBuffer sbf = new StringBuffer();
        // 查询 执行器名称为three的执行器,现在正在运行的任务
        List<XxlJobInfo> xxlJobInfos = xxlJobInfoMapper.queryThreeRunHandler();

        // 发送短信状态
        boolean sendStatus = false;
        if (xxlJobInfos != null && xxlJobInfos.size() > 0) {
            for (int i = 0; i < xxlJobInfos.size(); i++) {
                XxlJobInfo xxlJobInfo = xxlJobInfos.get(i);
                String executorHandler = xxlJobInfo.getExecutorHandler();
                //checkServer 和  reissue 过滤
                if (executorHandler.equals("checkServer") || executorHandler.equals("reissue")) continue;
                // 如果2分钟一次，每次拉取十分钟，失败了2次之后，第三次又成功了，这种的就不要发，没有连续10分钟没有数据
                // 查询最近12分钟内的执行条目
                List<XxlJobLog> xxlJobLogs = xxlJobLogMapper.queryTaskLastColumns(xxlJobInfo.getId());
                boolean pattern = true;
                if (xxlJobLogs != null && xxlJobLogs.size() > 0) {
                    for (int j = 0; j < xxlJobLogs.size(); j++) {
                        XxlJobLog xxlJobLog = xxlJobLogs.get(j);
                        // 失败的情况如下
//                    t.trigger_code NOT IN (0, 200) OR
//                    t.handle_code NOT IN (0, 200)
//                        if (!(
//                                !(xxlJobLog.getTriggerCode() == 0 || xxlJobLog.getTriggerCode() == 200) || !(xxlJobLog.getHandleCode() == 0 || xxlJobLog.getHandleCode() == 200)
//                        )) {
//                        // 有一条不为失败(调度和执行都成功),则不发送短信通知
                        if(xxlJobLog.getTriggerCode() == 200 && xxlJobLog.getHandleCode() == 200) {
                            pattern = false;
                            break;
                        }
                    }
                    if(pattern) {
                        sbf.append("jobHandler:" + xxlJobInfo.getExecutorHandler() + "连续失败多次;");
                        String result = "";
                        if(!sendStatus) {
                            result = sendSms(phone, "0000");
                        }
                        if(result.equals("OK")) {
                            sendStatus = true;
                        }
                    }

                }
            }
        }
        if(sendStatus) {
            sbf.append(";短信已通知");
        }
        return sbf.toString();
    }


//        for (String task : Constants.listenList) {
//            Date time = xxlJobLogDao.queryListenTask(task);
//
//            if (null == time || DateUtils.addMinute(new Date(), -7).after(time)) {//时间为空或者超过7分钟未执行定时器
//                // 手机号前要带国际区号,例如:中国则在手机号之前带86
////                String phone = configDao.getBySysKey("phone").getSysValue();
//                String key = "recordPhone:" + phone;
//                if (redisService.incrby(key, 0) < 3) {//12小时内最多连续发送三次短信提醒
//                    logger.error("游戏记录未执行,{}", phone);
//                    String res = commonService.sendSms("游戏记录未执行", phone, 0);
//                    if ("OK".equals(res)) {
//                        redisService.incrby(key, 1);
//                        redisService.setExpire(key, 12 * 60 * 60);
//                    }
//                }
//                break;
//            }
//        }


    public String sendSms(String phone, String remark) {
//        发送短信,一个小时最多发一个, 查询当前时间 和 当前时间一小时前的区间是否有成功反送过短信
        int i = smsConfigMapper.queryLastOneHourSuccessCnt();
        if(i != 0) {
            return "not";
        }


        Map<String,Object> smsRecordMap = new HashMap<>();
//        smsRecordMap.put("ip",ip);
//        smsRecordMap.put("deviceId",deviceId);
//        smsRecordMap.put("account",account);
//        smsRecordMap.put("way",loginFrom);


        // 查询短信服务
        Map<String, Object> smsMap = smsConfigMapper.querySmsConfigList("86");
        String result = "";
//        for (int i = 0; i < smsConfigList.size(); i++) {
//            Map<String, Object> smsMap = smsConfigList.get(i);
        Long id = (Long) smsMap.get("id");
        String name = (String) smsMap.get("name");
        String plateform = (String) smsMap.get("plateform");
        smsMap.put("accountPhone", phone);
        smsMap.put("accountCode", remark);//发送信息
        smsMap.put("accountAreaNum", (String) smsMap.get("area_code"));

        smsRecordMap.put("name",name);
        smsRecordMap.put("plateformId",id);
        smsRecordMap.put("remark",remark);
        smsRecordMap.put("plateform",plateform);
        smsRecordMap.put("phone",phone);

        result = smsSendingService.sendSms(SmsEnum.getChannel(plateform), smsMap);
        if ("OK".equals(result)) {
//                redisService.set(Constants.REDIS_BIND_PHONE_PREFIX + phone, remark, Constants.REDIS_BIND_VERITY_CODE_TIME);
            smsRecordMap.put("status","1");
            smsConfigMapper.saveSmsRecord(smsRecordMap);//保存发送记录
//                memberDao.updateSmsConfig(id,1,0);
            return "OK";

        }
        smsRecordMap.put("status","2");
//            logger.error("短信发送失败："+phone+"，平台:"+plateform);
        smsConfigMapper.saveSmsRecord(smsRecordMap);//保存发送记录
//            memberDao.updateSmsConfig(id,0,1);
//        }
        return "error";
    }

}
