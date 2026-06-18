package com.neverdisband;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class NeverDisbandApplication {

    public static void main(String[] args) {
        SpringApplication.run(NeverDisbandApplication.class, args);
    }
}
