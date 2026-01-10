package com.xxl.job.admin.controller.biz;

import com.xxl.job.admin.constant.Consts;
import com.xxl.job.admin.scheduler.config.XxlJobAdminBootstrap;
import com.xxl.job.admin.service.RedirectService;
import com.xxl.job.admin.util.HttpJsonUtil;
import com.xxl.job.admin.util.I18nUtil;
import com.xxl.sso.core.annotation.XxlSso;
import com.xxl.tool.core.StringTool;
import com.xxl.tool.json.GsonTool;
import com.xxl.tool.response.PageModel;
import com.xxl.tool.response.Response;
import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 期号查询（custom）：
 * - Admin 侧提供页面与接口
 * - 后端逻辑通过 RedirectService 选择执行器节点，然后转发到执行器的 /data/* 接口
 */
@Controller
@RequestMapping("/data")
public class DataController {

    private static final String TARGET_APPNAME = "three";

    @Resource
    private RedirectService redirectService;

    @RequestMapping
    @XxlSso(role = Consts.ADMIN_ROLE)
    public String index() {
        return "biz/data.list";
    }

    /**
     * 查询开奖信息（custom）
     */
    @RequestMapping("/kindId")
    @ResponseBody
    @XxlSso(role = Consts.ADMIN_ROLE)
    @SuppressWarnings("unchecked")
    public Response<PageModel<Map<String, Object>>> queryKindId(HttpServletRequest request,
                                                                @RequestParam(required = false, defaultValue = "0") int offset,
                                                                @RequestParam(required = false, defaultValue = "50") int pagesize,
                                                                @RequestParam(value = "kindId", required = false) String kindId,
                                                                @RequestParam(value = "periodNo", required = false) String periodNo) {

        String activeNode = redirectService.getActiveNode(TARGET_APPNAME);
        if (StringTool.isBlank(activeNode)) {
            return Response.ofFail("未找到可用执行器节点（appName=" + TARGET_APPNAME + "）");
        }

        try {
            String addressUrl = HttpJsonUtil.joinUrl(activeNode, request.getServletPath());
            Map<String, Object> reqMap = new HashMap<>();
            reqMap.put("kindId", kindId);
            reqMap.put("periodNo", periodNo);
            reqMap.put("start", offset);
            reqMap.put("length", pagesize);

            String resp = HttpJsonUtil.postJson(addressUrl,
                    XxlJobAdminBootstrap.getInstance().getAccessToken(),
                    XxlJobAdminBootstrap.getInstance().getTimeout(),
                    reqMap);

            Map<String, Object> resMap = GsonTool.fromJson(resp, Map.class);
            int listCount = toInt(resMap.get("recordsTotal"));
            List<Map<String, Object>> list = (List<Map<String, Object>>) resMap.get("data");

            PageModel<Map<String, Object>> pageModel = new PageModel<>();
            pageModel.setData(list);
            pageModel.setTotal(listCount);
            return Response.ofSuccess(pageModel);
        } catch (Exception e) {
            return Response.ofFail(I18nUtil.getString("system_api_error") + ": " + e.getMessage());
        }
    }

    private static int toInt(Object obj) {
        if (obj == null) {
            return 0;
        }
        if (obj instanceof Number) {
            return ((Number) obj).intValue();
        }
        String str = String.valueOf(obj).trim();
        try {
            return Integer.parseInt(str);
        } catch (Exception e) {
            return 0;
        }
    }
}



