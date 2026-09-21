package com.skillos;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class SkillOsApplication {
    public static void main(String[] args) {
        SpringApplication.run(SkillOsApplication.class, args);
    }
}
