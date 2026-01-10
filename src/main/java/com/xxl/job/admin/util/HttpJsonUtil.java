package com.xxl.job.admin.util;

import com.xxl.job.core.constant.Const;
import com.xxl.tool.core.StringTool;
import com.xxl.tool.json.GsonTool;

import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

/**
 * Simple http-json client for custom executor endpoints.
 */
public class HttpJsonUtil {

    private HttpJsonUtil() {
    }

    public static String joinUrl(String baseUrl, String path) {
        if (baseUrl == null) {
            baseUrl = "";
        }
        if (path == null) {
            path = "";
        }
        if (baseUrl.endsWith("/") && path.startsWith("/")) {
            return baseUrl.substring(0, baseUrl.length() - 1) + path;
        }
        if (!baseUrl.endsWith("/") && !path.startsWith("/")) {
            return baseUrl + "/" + path;
        }
        return baseUrl + path;
    }

    public static String postJson(String url,
                                 String accessToken,
                                 int timeoutSeconds,
                                 Object body) throws Exception {

        byte[] payload = GsonTool.toJson(body).getBytes(StandardCharsets.UTF_8);

        HttpURLConnection connection = (HttpURLConnection) new URL(url).openConnection();
        connection.setRequestMethod("POST");
        connection.setConnectTimeout(timeoutSeconds * 1000);
        connection.setReadTimeout(timeoutSeconds * 1000);
        connection.setDoOutput(true);
        connection.setRequestProperty("Content-Type", "application/json;charset=UTF-8");
        if (StringTool.isNotBlank(accessToken)) {
            connection.setRequestProperty(Const.XXL_JOB_ACCESS_TOKEN, accessToken);
        }

        try (OutputStream os = connection.getOutputStream()) {
            os.write(payload);
        }

        int respCode = connection.getResponseCode();
        InputStream inputStream = (respCode >= 200 && respCode < 300)
                ? connection.getInputStream()
                : connection.getErrorStream();

        if (inputStream == null) {
            return "";
        }
        try (inputStream) {
            return new String(inputStream.readAllBytes(), StandardCharsets.UTF_8);
        }
    }
}



