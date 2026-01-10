package com.xxl.job.admin.controller.biz;

import com.xxl.job.admin.constant.Consts;
import com.xxl.job.admin.model.BaseThreeGamePlatform;
import com.xxl.job.admin.scheduler.config.XxlJobAdminBootstrap;
import com.xxl.job.admin.service.RedirectService;
import com.xxl.job.admin.util.HttpJsonUtil;
import com.xxl.job.admin.util.I18nUtil;
import com.xxl.sso.core.annotation.XxlSso;
import com.xxl.tool.core.CollectionTool;
import com.xxl.tool.core.StringTool;
import com.xxl.tool.json.GsonTool;
import com.xxl.tool.response.PageModel;
import com.xxl.tool.response.Response;
import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 平台设置（custom）：
 * - Admin 侧提供页面与接口
 * - 后端逻辑通过 RedirectService 选择执行器节点，然后转发到执行器的 /plate/* 接口
 */
@Controller
@RequestMapping("/plate")
public class PlateController {

    private static final String TARGET_APPNAME = "three";

    @Resource
    private RedirectService redirectService;

    @RequestMapping
    @XxlSso(role = Consts.ADMIN_ROLE)
    public String index() {
        return "biz/plate.list";
    }

    @RequestMapping("/pageList")
    @ResponseBody
    @XxlSso(role = Consts.ADMIN_ROLE)
    @SuppressWarnings("unchecked")
    public Response<PageModel<Map<String, Object>>> pageList(HttpServletRequest request,
                                                             @RequestParam(required = false, defaultValue = "0") int offset,
                                                             @RequestParam(required = false, defaultValue = "10") int pagesize,
                                                             String serviceType,
                                                             String name) {

        String activeNode = redirectService.getActiveNode(TARGET_APPNAME);
        if (StringTool.isBlank(activeNode)) {
            return Response.ofFail("未找到可用执行器节点（appName=" + TARGET_APPNAME + "）");
        }

        try {
            String addressUrl = HttpJsonUtil.joinUrl(activeNode, request.getServletPath());

            Map<String, Object> reqMap = new HashMap<>();
            reqMap.put("serviceType", serviceType);
            reqMap.put("name", name);
            reqMap.put("start", offset);
            reqMap.put("length", pagesize);

            String resp = HttpJsonUtil.postJson(addressUrl,
                    XxlJobAdminBootstrap.getInstance().getAccessToken(),
                    XxlJobAdminBootstrap.getInstance().getTimeout(),
                    reqMap);

            Map<String, Object> resMap = GsonTool.fromJson(resp, Map.class);
            resMap = GsonTool.fromJson(resMap.get("content").toString(), Map.class);
            int listCount = toInt(resMap.get("recordsTotal"));
            List<Map<String, Object>> list = (List<Map<String, Object>>) resMap.get("data");
            // bootstrap-table expects "id" field; executor list should already contain it

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
    public Response<String> save(BaseThreeGamePlatform platform, HttpServletRequest request) {
        // valid (same as old version)
        if (platform == null
                || StringTool.isBlank(platform.getPlatformAccount())
                || StringTool.isBlank(platform.getPlatformUrl())
                || StringTool.isBlank(platform.getRecordUrl())
                || StringTool.isBlank(platform.getName())
                || StringTool.isBlank(platform.getServiceType())
                || StringTool.isBlank(platform.getPriKey())
                || StringTool.isBlank(platform.getPrefix())
                || StringTool.isBlank(platform.getWhiteList())) {
            return Response.ofFail("必填参数不能为空");
        }
        return forwardPost(platform, request);
    }

    @RequestMapping("/update")
    @ResponseBody
    @XxlSso(role = Consts.ADMIN_ROLE)
    public Response<String> update(BaseThreeGamePlatform platform, HttpServletRequest request) {
        // valid (same as old version)
        if (platform == null
                || StringTool.isBlank(platform.getPlatformAccount())
                || StringTool.isBlank(platform.getPlatformUrl())
                || StringTool.isBlank(platform.getRecordUrl())
                || StringTool.isBlank(platform.getName())
                || StringTool.isBlank(platform.getServiceType())
                || StringTool.isBlank(platform.getPrefix())
                || StringTool.isBlank(platform.getWhiteList())) {
            return Response.ofFail("必填参数不能为空");
        }
        return forwardPost(platform, request);
    }

    @RequestMapping("/remove")
    @ResponseBody
    @XxlSso(role = Consts.ADMIN_ROLE)
    public Response<String> remove(@RequestParam("ids[]") List<Long> ids, HttpServletRequest request) {
        if (CollectionTool.isEmpty(ids) || ids.size() != 1) {
            return Response.ofFail(I18nUtil.getString("system_please_choose") + I18nUtil.getString("system_one") + I18nUtil.getString("system_data"));
        }
        return forwardPost(String.valueOf(ids.get(0)), request);
    }

    @GetMapping("/history/{serviceType}/{platformAccount}")
    @XxlSso(role = Consts.ADMIN_ROLE)
    public String history(@PathVariable("serviceType") String type,
                          @PathVariable("platformAccount") String platformAccount,
                          Model model) {
        model.addAttribute("serviceType", type);
        model.addAttribute("platformAccount", platformAccount);
        return "biz/plate.history";
    }

    @PostMapping("/history")
    @ResponseBody
    @XxlSso(role = Consts.ADMIN_ROLE)
    public Response<String> history(@RequestBody Map<String, String> map, HttpServletRequest request) {
        // custom timeout
        int timeout = 3;
        if (map != null) {
            String serviceType = map.get("serviceType");
            if ("tcg_tcg".equals(serviceType)) {
                timeout = 12;
            }
            if (StringTool.isNotBlank(serviceType) && (serviceType.startsWith("ly_ly") || serviceType.startsWith("w_9"))) {
                timeout = 30;
            }
        }
        return forwardPost(map, request, timeout);
    }

    @GetMapping("/sumOrder/{type}")
    @XxlSso(role = Consts.ADMIN_ROLE)
    public String sumOrder(@PathVariable("type") String type, Model model) {
        model.addAttribute("type", type);
        return "biz/plate.sumOrder";
    }

    @GetMapping("/sumOrder")
    @ResponseBody
    @XxlSso(role = Consts.ADMIN_ROLE)
    public Response<String> sumOrder(@RequestParam("type") String type,
                                     @RequestParam("date") String date,
                                     HttpServletRequest request) {

        Map<String, Object> map = new HashMap<>();
        map.put("type", type);
        map.put("date", date);
        return forwardPost(map, request, 50);
    }

    private Response<String> forwardPost(Object body, HttpServletRequest request) {
        return forwardPost(body, request, XxlJobAdminBootstrap.getInstance().getTimeout());
    }

    private Response<String> forwardPost(Object body, HttpServletRequest request, int timeoutSeconds) {
        String activeNode = redirectService.getActiveNode(TARGET_APPNAME);
        if (StringTool.isBlank(activeNode)) {
            return Response.ofFail("未找到可用执行器节点（appName=" + TARGET_APPNAME + "）");
        }

        try {
            String addressUrl = HttpJsonUtil.joinUrl(activeNode, request.getServletPath());
            String resp = HttpJsonUtil.postJson(addressUrl,
                    XxlJobAdminBootstrap.getInstance().getAccessToken(),
                    timeoutSeconds,
                    body);
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


