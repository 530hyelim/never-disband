package com.neverdisband.dao;

import com.neverdisband.config.OAuthConfig;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL JDBC Driver not found", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(
                OAuthConfig.getDbUrl(),
                OAuthConfig.getDbUser(),
                OAuthConfig.getDbPassword()
        );
    }
}
