package com.xxl.job.admin.util;

import java.util.Arrays;
import java.util.Objects;

//@Getter
//@AllArgsConstructor
public enum SmsEnum {

    ALI_YUN("2", "阿里云短信"),
    ;

    private final String code;

    private final String name;

    public static SmsEnum getChannel(String code) {
        SmsEnum smsEnum = Arrays.stream(SmsEnum.values())
                .filter(channel -> Objects.equals(channel.getCode(), code)).findFirst().orElse(null);
        return smsEnum;
    }


    SmsEnum(String code, String name) {
        this.code = code;
        this.name = name;
    }


    public String getCode() {
        return code;
    }

    public String getName() {
        return name;
    }
}
