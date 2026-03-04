package com.xxl.job.admin.util;

import net.sourceforge.pinyin4j.PinyinHelper;
import net.sourceforge.pinyin4j.format.HanyuPinyinCaseType;
import net.sourceforge.pinyin4j.format.HanyuPinyinOutputFormat;
import net.sourceforge.pinyin4j.format.HanyuPinyinToneType;
import net.sourceforge.pinyin4j.format.exception.BadHanyuPinyinOutputFormatCombination;

/**
 * 拼音工具类
 */
public class PinyinUtil {

    private static final HanyuPinyinOutputFormat FORMAT = new HanyuPinyinOutputFormat();

    static {
        FORMAT.setCaseType(HanyuPinyinCaseType.LOWERCASE);
        FORMAT.setToneType(HanyuPinyinToneType.WITHOUT_TONE);
    }

    /**
     * 将中文描述转换为拼音首字母编码，保留原有的英文字母和数字
     *
     * @param chinese 中文描述
     * @return 拼音首字母编码
     */
    public static String toPinyinCode(String chinese) {
        if (chinese == null || chinese.isEmpty()) {
            return "";
        }
        StringBuilder sb = new StringBuilder();
        for (char c : chinese.toCharArray()) {
            if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9')) {
                sb.append(c);
            } else {
                try {
                    String[] pinyinArray = PinyinHelper.toHanyuPinyinStringArray(c, FORMAT);
                    if (pinyinArray != null && pinyinArray.length > 0) {
                        sb.append(pinyinArray[0].charAt(0));
                    }
                } catch (BadHanyuPinyinOutputFormatCombination e) {
                    // skip non-convertible characters
                }
            }
        }
        return sb.toString().toLowerCase();
    }

}
