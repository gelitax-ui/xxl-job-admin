package com.xxl.job.admin.scheduler.config;

import com.xxl.job.admin.service.SmsService;
import com.xxl.job.admin.util.SmsEnum;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Configuration
public class SmsServiceConfig {

    @Bean
    public Map<SmsEnum, SmsService> smsServiceMap(List<SmsService> services) {
        return services.stream()
                .collect(Collectors.toMap(SmsService::getProvider, Function.identity()));
    }
}
