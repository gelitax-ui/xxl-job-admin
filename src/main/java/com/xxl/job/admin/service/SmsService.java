package com.xxl.job.admin.service;



import com.xxl.job.admin.util.SmsEnum;

import java.util.Map;

public interface SmsService {
    boolean sendSms(Map<String, Object> smsMap);

    SmsEnum getProvider();
}
