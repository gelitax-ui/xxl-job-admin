package com.xxl.job.admin.service.impl;

//import cn.hutool.json.JSONUtil;
import com.alibaba.fastjson.JSON;
import com.aliyun.dysmsapi20170525.models.SendSmsResponse;
import com.aliyun.tea.TeaException;
import com.xxl.job.admin.service.SmsService;
import com.xxl.job.admin.util.SmsEnum;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
public class AliyunSmsServiceImpl implements SmsService {
    private static final Logger logger = LoggerFactory.getLogger(AliyunSmsServiceImpl.class);
    @Override
    public boolean sendSms(Map<String, Object> smsMap) {

        String accessKeyId = (String) smsMap.get("access_key_id");
        String accessSecret = (String) smsMap.get("access_secret");
        String PhoneNumbers = (String) smsMap.get("accountPhone");
        String SignName = (String) smsMap.get("sign_name");
        String TemplateCode = (String) smsMap.get("template_id");
        String code = (String) smsMap.get("accountCode");
        String areaNum = (String) smsMap.get("accountAreaNum");

        SendSmsResponse sendSmsResponse = new SendSmsResponse();

        if("86".equals(areaNum)){//中国
            com.aliyun.teaopenapi.models.Config config = new com.aliyun.teaopenapi.models.Config()
                    // 必填，您的 AccessKey ID
                    .setAccessKeyId(accessKeyId)
                    // 必填，您的 AccessKey Secret
                    .setAccessKeySecret(accessSecret);
            // Endpoint 请参考 https://api.aliyun.com/product/Dysmsapi
            config.endpoint = "dysmsapi.aliyuncs.com";
            // 特化请求客户端
            try {
                Map<String, String> paramMap = new HashMap<>();
                paramMap.put("code", code);
                com.aliyun.dysmsapi20170525.Client dysmsapiClient = new com.aliyun.dysmsapi20170525.Client(config);
                com.aliyun.dysmsapi20170525.models.SendSmsRequest sendSmsRequest = new com.aliyun.dysmsapi20170525.models.SendSmsRequest()
                    .setPhoneNumbers(PhoneNumbers)
                    .setSignName(SignName)
                    .setTemplateCode(TemplateCode)
//                    .setTemplateParam(JSONUtil.toJsonStr(paramMap));
                    .setTemplateParam(JSON.toJSONString(paramMap));
                com.aliyun.teautil.models.RuntimeOptions runtime = new com.aliyun.teautil.models.RuntimeOptions();
                try {
                    sendSmsResponse = dysmsapiClient.sendSmsWithOptions(sendSmsRequest, runtime);
                    if( 200==sendSmsResponse.getStatusCode() ){
                        if("OK".equals(sendSmsResponse.getBody().getCode())){
                            return true;
                        }
                        logger.error("阿里云短信失败3：phone："+PhoneNumbers+","+sendSmsResponse.getBody().getMessage());
                    }
                }  catch (Exception _error) {
                    TeaException error = new TeaException(_error.getMessage(), _error);
                    logger.error("阿里云短信失败1：phone："+PhoneNumbers+","+error.getMessage());
                }
            } catch (Exception e) {
                logger.error("阿里云短信失败2：phone："+PhoneNumbers+","+e.getMessage());
            }
        }
        logger.error("阿里云短信失败4：phone："+PhoneNumbers);
        return false;
    }

    @Override
    public SmsEnum getProvider() {
        return SmsEnum.ALI_YUN;
    }
}