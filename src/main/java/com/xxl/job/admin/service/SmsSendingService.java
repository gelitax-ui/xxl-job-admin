package com.xxl.job.admin.service;

import com.xxl.job.admin.util.SmsEnum;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class SmsSendingService {

    private final Map<SmsEnum, SmsService> smsServiceMap;

    public SmsSendingService(Map<SmsEnum, SmsService> smsServiceMap) {
        this.smsServiceMap = smsServiceMap;
    }

    public String sendSms(SmsEnum provider, Map<String, Object> smsMap) {
        SmsService smsService = smsServiceMap.get(provider);
        if (smsService == null) {
            throw new IllegalArgumentException("未获取到对应的短信服务: " + provider);
        }
        //截取首位0
        String accountPhone = (String) smsMap.get("accountPhone");
        String accountAreaNum = (String) smsMap.get("accountAreaNum");
        String phoneSub = accountPhone.replace(accountAreaNum,"");
        if(phoneSub.startsWith("0")) accountPhone = accountAreaNum + phoneSub.substring(1,phoneSub.length());
        smsMap.put("accountPhone",accountPhone);
        boolean flag = smsService.sendSms(smsMap);
        return flag?"OK":"error";
    }
}
