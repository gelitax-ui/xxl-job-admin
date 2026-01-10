package com.xxl.job.admin.controller.biz;

import com.xxl.job.admin.constant.Consts;
import com.xxl.job.admin.scheduler.config.XxlJobAdminBootstrap;
import com.xxl.job.admin.service.RedirectService;
import com.xxl.job.admin.util.HttpJsonUtil;
import com.xxl.job.admin.util.I18nUtil;
import com.xxl.tool.core.CollectionTool;
import com.xxl.tool.core.StringTool;
import com.xxl.tool.json.GsonTool;
import com.xxl.tool.response.PageModel;
import com.xxl.tool.response.Response;
import com.xxl.sso.core.annotation.XxlSso;
import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 系统配置（custom）：
 * - Admin 侧提供页面与接口
 * - 后端逻辑通过 RedirectService 选择执行器节点，然后转发到执行器的 /conf/* 接口
 */
@Controller
@RequestMapping("/conf")
public class ConfController {

    private static final String TARGET_APPNAME = "three";

    @Resource
    private RedirectService redirectService;

    @RequestMapping
    @XxlSso(role = Consts.ADMIN_ROLE)
    public String index() {
        return "biz/conf.list";
    }

    @RequestMapping("/pageList")
    @ResponseBody
    @XxlSso(role = Consts.ADMIN_ROLE)
    @SuppressWarnings("unchecked")
    public Response<PageModel<Map<String, Object>>> pageList(HttpServletRequest request,
                                                             @RequestParam(required = false, defaultValue = "0") int offset,
                                                             @RequestParam(required = false, defaultValue = "10") int pagesize,
                                                             String sysKey) {

        String activeNode = redirectService.getActiveNode(TARGET_APPNAME);
        if (StringTool.isBlank(activeNode)) {
            return Response.ofFail("未找到可用执行器节点（appName=" + TARGET_APPNAME + "）");
        }

        try {
            String addressUrl = HttpJsonUtil.joinUrl(activeNode, request.getServletPath());

            Map<String, Object> reqMap = new HashMap<>();
            reqMap.put("start", offset);
            reqMap.put("length", pagesize);
            reqMap.put("sysKey", sysKey);

            String resp = HttpJsonUtil.postJson(addressUrl,
                    XxlJobAdminBootstrap.getInstance().getAccessToken(),
                    XxlJobAdminBootstrap.getInstance().getTimeout(),
                    reqMap);

            Map<String, Object> resMap = GsonTool.fromJson(resp, Map.class);
            resMap = GsonTool.fromJson(resMap.get("content").toString(), Map.class);
            int listCount = toInt(resMap.get("recordsTotal"));
            List<Map<String, Object>> list = (List<Map<String, Object>>) resMap.get("data");
            if (CollectionTool.isNotEmpty(list)) {
                for (Map<String, Object> item : list) {
                    // bootstrap-table needs "id"
                    Object key = item.get("sysKey");
                    item.put("id", key != null ? String.valueOf(key) : null);
                }
            }

            PageModel<Map<String, Object>> pageModel = new PageModel<>();
            pageModel.setData(list);
            pageModel.setTotal(listCount);
            return Response.ofSuccess(pageModel);
        } catch (Exception e) {
            return Response.ofFail(I18nUtil.getString("system_api_error") + ": " + e.getMessage());
        }
    }

    @RequestMapping("/save")
    @ResponseBody
    @XxlSso(role = Consts.ADMIN_ROLE)
    public Response<String> save(@RequestParam Map<String, Object> config, HttpServletRequest request) {
        return saveOrUpdate(config, request);
    }

    @RequestMapping("/update")
    @ResponseBody
    @XxlSso(role = Consts.ADMIN_ROLE)
    public Response<String> update(@RequestParam Map<String, Object> config, HttpServletRequest request) {
        return saveOrUpdate(config, request);
    }

    private Response<String> saveOrUpdate(Map<String, Object> config, HttpServletRequest request) {
        if (config == null
                || StringTool.isBlank(String.valueOf(config.get("sysKey")))
                || StringTool.isBlank(String.valueOf(config.get("sysValue")))) {
            return Response.ofFail("必填参数不能为空");
        }

        String activeNode = redirectService.getActiveNode(TARGET_APPNAME);
        if (StringTool.isBlank(activeNode)) {
            return Response.ofFail("未找到可用执行器节点（appName=" + TARGET_APPNAME + "）");
        }

        try {
            String addressUrl = HttpJsonUtil.joinUrl(activeNode, request.getServletPath());
            String resp = HttpJsonUtil.postJson(addressUrl,
                    XxlJobAdminBootstrap.getInstance().getAccessToken(),
                    XxlJobAdminBootstrap.getInstance().getTimeout(),
                    config);
            return mapRemoteResp(resp);
        } catch (Exception e) {
            return Response.ofFail(I18nUtil.getString("system_api_error") + ": " + e.getMessage());
        }
    }

    @RequestMapping("/remove")
    @ResponseBody
    @XxlSso(role = Consts.ADMIN_ROLE)
    public Response<String> remove(@RequestParam("ids[]") List<String> ids, HttpServletRequest request) {
        if (CollectionTool.isEmpty(ids) || ids.size() != 1) {
            return Response.ofFail(I18nUtil.getString("system_please_choose") + I18nUtil.getString("system_one") + I18nUtil.getString("system_data"));
        }

        String activeNode = redirectService.getActiveNode(TARGET_APPNAME);
        if (StringTool.isBlank(activeNode)) {
            return Response.ofFail("未找到可用执行器节点（appName=" + TARGET_APPNAME + "）");
        }

        try {
            String addressUrl = HttpJsonUtil.joinUrl(activeNode, request.getServletPath());
            String resp = HttpJsonUtil.postJson(addressUrl,
                    XxlJobAdminBootstrap.getInstance().getAccessToken(),
                    XxlJobAdminBootstrap.getInstance().getTimeout(),
                    ids.get(0));

            // old executor may return "1" or json
            Response<String> mapped = mapRemoteResp(resp);
            if (mapped.getCode() == 200) {
                return Response.ofSuccess();
            }
            // fallback: parse integer
            int ret = toInt(resp);
            return (ret > 0) ? Response.ofSuccess() : Response.ofFail();
        } catch (Exception e) {
            return Response.ofFail(I18nUtil.getString("system_api_error") + ": " + e.getMessage());
        }
    }

    /**
     * 检测域名（custom）
     */
    @RequestMapping("/checkNet")
    @ResponseBody
    @XxlSso(role = Consts.ADMIN_ROLE)
    public Response<String> checkNet(@RequestParam("sysKey") String sysKey, HttpServletRequest request) {
        if (StringTool.isBlank(sysKey)) {
            return Response.ofFail("必填参数不能为空");
        }

        String activeNode = redirectService.getActiveNode(TARGET_APPNAME);
        if (StringTool.isBlank(activeNode)) {
            return Response.ofFail("未找到可用执行器节点（appName=" + TARGET_APPNAME + "）");
        }

        try {
            String addressUrl = HttpJsonUtil.joinUrl(activeNode, request.getServletPath());
            String resp = HttpJsonUtil.postJson(addressUrl,
                    XxlJobAdminBootstrap.getInstance().getAccessToken(),
                    XxlJobAdminBootstrap.getInstance().getTimeout(),
                    sysKey);
            return mapRemoteResp(resp);
        } catch (Exception e) {
            return Response.ofFail(I18nUtil.getString("system_api_error") + ": " + e.getMessage());
        }
    }

    private static Response<String> mapRemoteResp(String resp) {
        if (StringTool.isBlank(resp)) {
            return Response.ofFail();
        }

        String trim = resp.trim();
        try {
            if (trim.startsWith("{") && trim.endsWith("}")) {
                @SuppressWarnings("unchecked")
                Map<String, Object> map = GsonTool.fromJson(trim, Map.class);
                int code = toInt(map.get("code"));
                String msg = map.get("msg") != null ? String.valueOf(map.get("msg")) : null;
                if (code == 200) {
                    return Response.ofSuccess();
                }
                return Response.ofFail(msg);
            }
        } catch (Exception ignore) {
        }

        // plain response
        if ("1".equals(trim) || "\"1\"".equals(trim)) {
            return Response.ofSuccess();
        }
        return Response.ofFail(trim);
    }

    private static int toInt(Object obj) {
        if (obj == null) {
            return 0;
        }
        if (obj instanceof Number) {
            return ((Number) obj).intValue();
        }
        String str = String.valueOf(obj).trim();
        if (str.startsWith("\"") && str.endsWith("\"") && str.length() >= 2) {
            str = str.substring(1, str.length() - 1);
        }
        try {
            return Integer.parseInt(str);
        } catch (Exception e) {
            return 0;
        }
    }
}


