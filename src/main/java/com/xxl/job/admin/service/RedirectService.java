package com.xxl.job.admin.service;

import com.xxl.job.admin.mapper.XxlJobGroupMapper;
import com.xxl.job.admin.model.XxlJobGroup;
import com.xxl.job.admin.scheduler.config.XxlJobAdminBootstrap;
import com.xxl.job.admin.util.I18nUtil;
import com.xxl.job.core.openapi.ExecutorBiz;
import com.xxl.tool.core.StringTool;
import com.xxl.tool.response.Response;
import jakarta.annotation.Resource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.List;

/**
 * Select an active executor node by appName, similar to failover strategy.
 *
 * Note: This is for custom features that proxy requests to a dedicated executor (e.g. appName="three").
 */
@Service
public class RedirectService {

    private static final Logger logger = LoggerFactory.getLogger(RedirectService.class);

    @Resource
    private XxlJobGroupMapper xxlJobGroupMapper;

    /**
     * Get current active node (first beat-success address) by appName.
     */
    public String getActiveNode(String appName) {
        if (StringTool.isBlank(appName)) {
            return null;
        }

        StringBuffer beatResultSB = new StringBuffer();

        XxlJobGroup group = xxlJobGroupMapper.findByAppName(appName);
        if (group == null || StringTool.isBlank(group.getAddressList())) {
            return null;
        }

        String[] split = group.getAddressList().split(",");
        List<String> addressList = Arrays.stream(split)
                .map(String::trim)
                .filter(StringTool::isNotBlank)
                .toList();

        for (String address : addressList) {
            // beat
            Response<String> beatResult;
            try {
                ExecutorBiz executorBiz = XxlJobAdminBootstrap.getExecutorBiz(address);
                beatResult = executorBiz.beat();
            } catch (Exception e) {
                logger.error(e.getMessage(), e);
                return null;
            }

            beatResultSB.append((beatResultSB.length() > 0) ? "<br><br>" : "")
                    .append(I18nUtil.getString("jobconf_beat") + "：")
                    .append("<br>address：").append(address)
                    .append("<br>code：").append(beatResult.getCode())
                    .append("<br>msg：").append(beatResult.getMsg());

            // beat success
            if (beatResult.isSuccess()) {
                return address;
            }
        }

        return null;
    }
}



