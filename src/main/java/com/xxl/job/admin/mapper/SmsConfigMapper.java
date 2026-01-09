package com.xxl.job.admin.mapper;

import org.apache.ibatis.annotations.Mapper;

import java.util.Map;


/**
 * job info
 * @author xuxueli 2016-1-12 18:03:45
 */
@Mapper
public interface SmsConfigMapper {

	Map<String,Object> querySmsConfigList(String areaCode);

	int saveSmsRecord(Map<String, Object> smsRecordMap);

	int queryLastOneHourSuccessCnt();

//	int updateSmsConfig(@Param("id") Long id, @Param("successCnt") Integer successCnt, @Param("failCnt") Integer failCnt);

}
