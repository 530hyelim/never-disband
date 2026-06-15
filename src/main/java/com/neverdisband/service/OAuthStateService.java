package com.neverdisband.service;

import com.neverdisband.config.OAuthConfig;
import org.springframework.stereotype.Service;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;

/**
 * OAuth state 파라미터를 HMAC-SHA256 서명 기반으로 생성/검증
 *
 * 세션에 state를 저장하는 방식은 Discord 리다이렉트 도중 다른 요청이
 * /login을 재호출하면 state가 덮어씌워지는 문제가 발생
 * HMAC 방식은 세션 의존 없이 서버 비밀키로 서명을 검증하므로 이 문제가 없음
 *
 * state 형식: base64url(timestamp) + "." + base64url(HMAC(timestamp))
 */
@Service
public class OAuthStateService {

    private static final String HMAC_ALGO = "HmacSHA256";
    // state 유효 시간: 10분
    private static final long STATE_EXPIRY_MS = 10 * 60 * 1000L;

    private final byte[] secretKey;

    public OAuthStateService(OAuthConfig oAuthConfig) {
        this.secretKey = oAuthConfig.getClientSecret().getBytes(StandardCharsets.UTF_8);
    }

    /**
     * 서명된 state 문자열을 생성
     */
    public String generate() {
        String timestamp = String.valueOf(System.currentTimeMillis());
        String encodedTs = Base64.getUrlEncoder().withoutPadding()
                .encodeToString(timestamp.getBytes(StandardCharsets.UTF_8));
        String sig = hmac(encodedTs);
        return encodedTs + "." + sig;
    }

    /**
     * state가 유효한지 검증
     * - 서명 일치 여부
     * - 10분 이내 발급 여부
     */
    public boolean validate(String state) {
        if (state == null || !state.contains(".")) return false;

        int dot = state.lastIndexOf('.');
        String encodedTs = state.substring(0, dot);
        String receivedSig = state.substring(dot + 1);

        // 서명 검증
        String expectedSig = hmac(encodedTs);
        if (!constantTimeEquals(expectedSig, receivedSig)) return false;

        // 만료 검증
        try {
            String timestamp = new String(
                    Base64.getUrlDecoder().decode(encodedTs), StandardCharsets.UTF_8);
            long issuedAt = Long.parseLong(timestamp);
            return System.currentTimeMillis() - issuedAt <= STATE_EXPIRY_MS;
        } catch (Exception e) {
            return false;
        }
    }

    private String hmac(String data) {
        try {
            Mac mac = Mac.getInstance(HMAC_ALGO);
            mac.init(new SecretKeySpec(secretKey, HMAC_ALGO));
            byte[] raw = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            return Base64.getUrlEncoder().withoutPadding().encodeToString(raw);
        } catch (NoSuchAlgorithmException | InvalidKeyException e) {
            throw new IllegalStateException("HMAC 초기화 실패", e);
        }
    }

    // 타이밍 공격 방지를 위한 상수 시간 비교
    private boolean constantTimeEquals(String a, String b) {
        if (a.length() != b.length()) return false;
        int result = 0;
        for (int i = 0; i < a.length(); i++) {
            result |= a.charAt(i) ^ b.charAt(i);
        }
        return result == 0;
    }
}
