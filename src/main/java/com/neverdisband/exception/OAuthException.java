package com.neverdisband.exception;

public class OAuthException extends Exception {

    public enum ErrorType {
        CONNECTION_FAILED,
        TOKEN_EXCHANGE_FAILED,
        USER_INFO_FAILED,
        STATE_MISMATCH
    }

    private final ErrorType type;

    public OAuthException(ErrorType type, String message) {
        super(message);
        this.type = type;
    }

    public OAuthException(ErrorType type, String message, Throwable cause) {
        super(message, cause);
        this.type = type;
    }

    public ErrorType getType() {
        return type;
    }
}
