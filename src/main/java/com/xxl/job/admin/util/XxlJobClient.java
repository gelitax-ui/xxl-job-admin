package com.xxl.job.admin.util;

import com.xxl.tool.json.GsonTool;
import com.xxl.tool.response.Response;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.net.ssl.*;
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.cert.X509Certificate;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * XXL-JOB 客户端 SDK（参考代码）
 *
 * <p>用法示例：</p>
 * <pre>
 * XxlJobClient client = new XxlJobClient("http://localhost:8080/xxl-job-admin", "your-token", "my-app");
 *
 * // 增加任务并自动启动
 * client.addJob("myJobCode", new Date(...), "myHandler", Map.of("key", "value"));
 *
 * // 更新任务
 * client.updateJob("myJobCode", newDate, "myHandler", Map.of("key", "newValue"));
 *
 * // 查询任务
 * client.queryJob("myJobCode");
 *
 * // 删除任务
 * client.removeJob("myJobCode");
 * </pre>
 */
public class XxlJobClient {
    private static final Logger logger = LoggerFactory.getLogger(XxlJobClient.class);
    private static final String DATE_FORMAT = "yyyy-MM-dd HH:mm:ss";
    private static final String ACCESS_TOKEN_HEADER = "XXL-JOB-ACCESS-TOKEN";

    private final String adminAddress;
    private final String accessToken;
    private final String groupAppName;
    private final int timeout;

    /**
     * @param adminAddress  admin服务地址，如 http://localhost:8080/xxl-job-admin
     * @param accessToken   访问令牌
     * @param groupAppName  执行器AppName
     */
    public XxlJobClient(String adminAddress, String accessToken, String groupAppName) {
        this(adminAddress, accessToken, groupAppName, 5);
    }

    /**
     * @param adminAddress  admin服务地址
     * @param accessToken   访问令牌
     * @param groupAppName  执行器AppName
     * @param timeout       请求超时（秒）
     */
    public XxlJobClient(String adminAddress, String accessToken, String groupAppName, int timeout) {
        if (adminAddress != null && !adminAddress.endsWith("/")) {
            adminAddress = adminAddress + "/";
        }
        this.adminAddress = adminAddress;
        this.accessToken = accessToken;
        this.groupAppName = groupAppName;
        this.timeout = Math.max(1, Math.min(timeout, 30));
    }

    // -------------------- 任务操作 --------------------

    /**
     * 增加任务（自动启动）
     *
     * @param jobCode         任务编码
     * @param triggerTime     执行时间
     * @param executorHandler JobHandler名称
     * @param executorParam   任务参数
     */
    public Response<String> addJob(String jobCode, Date triggerTime, String executorHandler, Map<String, Object> executorParam) {
        return addJob(jobCode, triggerTime, executorHandler, executorParam, null);
    }

    /**
     * 增加任务（自动启动），支持可选参数
     *
     * @param jobCode         任务编码
     * @param triggerTime     执行时间
     * @param executorHandler JobHandler名称
     * @param executorParam   任务参数
     * @param options         可选参数（jobDesc, author, executorTimeout, executorFailRetryCount, remark）
     */
    public Response<String> addJob(String jobCode, Date triggerTime, String executorHandler, Map<String, Object> executorParam, Map<String, Object> options) {
        Map<String, Object> body = buildJobBody(jobCode, triggerTime, executorHandler, executorParam, options);
        return postApi("jobAdd", body, String.class);
    }

    /**
     * 更新任务（自动重启）
     *
     * @param jobCode         任务编码
     * @param triggerTime     执行时间
     * @param executorHandler JobHandler名称
     * @param executorParam   任务参数
     */
    public Response<String> updateJob(String jobCode, Date triggerTime, String executorHandler, Map<String, Object> executorParam) {
        return updateJob(jobCode, triggerTime, executorHandler, executorParam, null);
    }

    /**
     * 更新任务（自动重启），支持可选参数
     */
    public Response<String> updateJob(String jobCode, Date triggerTime, String executorHandler, Map<String, Object> executorParam, Map<String, Object> options) {
        Map<String, Object> body = buildJobBody(jobCode, triggerTime, executorHandler, executorParam, options);
        return postApi("jobUpdate", body, String.class);
    }

    /**
     * 删除任务
     *
     * @param jobCode 任务编码
     */
    public Response<String> removeJob(String jobCode) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("groupAppName", groupAppName);
        body.put("jobCode", jobCode);
        return postApi("jobRemove", body, String.class);
    }

    /**
     * 查询任务
     *
     * @param jobCode 任务编码
     */
    public Response<String> queryJob(String jobCode) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("groupAppName", groupAppName);
        body.put("jobCode", jobCode);
        return postApi("jobQuery", body, String.class);
    }

    /**
     * 重置任务触发时间
     *
     * @param jobCode     任务编码
     * @param triggerTime 新的执行时间
     */
    public Response<String> resetTriggerTime(String jobCode, Date triggerTime) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("groupAppName", groupAppName);
        body.put("jobCode", jobCode);
        body.put("triggerTime", formatDate(triggerTime));
        return postApi("jobResetTriggerTime", body, String.class);
    }

    // -------------------- internal --------------------

    private Map<String, Object> buildJobBody(String jobCode, Date triggerTime, String executorHandler, Map<String, Object> executorParam, Map<String, Object> options) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("groupAppName", groupAppName);
        body.put("jobCode", jobCode);
        body.put("triggerTime", formatDate(triggerTime));
        body.put("executorHandler", executorHandler);
        body.put("executorParam", GsonTool.toJson(executorParam));

        if (options != null) {
            if (options.containsKey("jobDesc")) {
                body.put("jobDesc", options.get("jobDesc"));
            }
            if (options.containsKey("author")) {
                body.put("author", options.get("author"));
            }
            if (options.containsKey("executorTimeout")) {
                body.put("executorTimeout", options.get("executorTimeout"));
            }
            if (options.containsKey("executorFailRetryCount")) {
                body.put("executorFailRetryCount", options.get("executorFailRetryCount"));
            }
            if (options.containsKey("remark")) {
                body.put("remark", options.get("remark"));
            }
        }

        return body;
    }

    private String formatDate(Date date) {
        if (date == null) {
            return "";
        }
        return new SimpleDateFormat(DATE_FORMAT).format(date);
    }

    @SuppressWarnings("unchecked")
    private <T> Response<T> postApi(String uri, Object requestBody, Class<T> returnType) {
        HttpURLConnection connection = null;
        BufferedReader bufferedReader = null;
        DataOutputStream dataOutputStream = null;
        try {
            String url = adminAddress + "api/" + uri;

            URL realUrl = new URL(url);
            connection = (HttpURLConnection) realUrl.openConnection();

            if (url.startsWith("https")) {
                trustAllHosts((HttpsURLConnection) connection);
            }

            connection.setRequestMethod("POST");
            connection.setDoOutput(true);
            connection.setDoInput(true);
            connection.setUseCaches(false);
            connection.setReadTimeout(timeout * 1000);
            connection.setConnectTimeout(timeout * 1000);
            connection.setRequestProperty("Content-Type", "application/json;charset=UTF-8");
            connection.setRequestProperty("Accept-Charset", "application/json;charset=UTF-8");

            if (accessToken != null && !accessToken.trim().isEmpty()) {
                connection.setRequestProperty(ACCESS_TOKEN_HEADER, accessToken);
            }

            connection.connect();

            if (requestBody != null) {
                String json = GsonTool.toJson(requestBody);
                dataOutputStream = new DataOutputStream(connection.getOutputStream());
                dataOutputStream.write(json.getBytes("UTF-8"));
                dataOutputStream.flush();
            }

            int statusCode = connection.getResponseCode();
            if (statusCode != 200) {
                return Response.ofFail("request fail, StatusCode(" + statusCode + "), url=" + url);
            }

            bufferedReader = new BufferedReader(new InputStreamReader(connection.getInputStream(), "UTF-8"));
            StringBuilder result = new StringBuilder();
            String line;
            while ((line = bufferedReader.readLine()) != null) {
                result.append(line);
            }

            return GsonTool.fromJson(result.toString(), Response.class, returnType);
        } catch (Exception e) {
            logger.error("xxl-job client error, uri={}", uri, e);
            return Response.ofFail("request error: " + e.getMessage());
        } finally {
            try {
                if (dataOutputStream != null) dataOutputStream.close();
                if (bufferedReader != null) bufferedReader.close();
                if (connection != null) connection.disconnect();
            } catch (Exception ignored) {
            }
        }
    }

    private static void trustAllHosts(HttpsURLConnection connection) {
        try {
            SSLContext sc = SSLContext.getInstance("TLS");
            sc.init(null, TRUST_ALL_CERTS, new java.security.SecureRandom());
            connection.setSSLSocketFactory(sc.getSocketFactory());
        } catch (Exception e) {
            logger.error(e.getMessage(), e);
        }
        connection.setHostnameVerifier((hostname, session) -> true);
    }

    private static final TrustManager[] TRUST_ALL_CERTS = new TrustManager[]{new X509TrustManager() {
        @Override
        public X509Certificate[] getAcceptedIssuers() { return new X509Certificate[]{}; }
        @Override
        public void checkClientTrusted(X509Certificate[] chain, String authType) { }
        @Override
        public void checkServerTrusted(X509Certificate[] chain, String authType) { }
    }};

}
