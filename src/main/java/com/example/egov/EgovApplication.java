package com.example.egov;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 애플리케이션 진입점
 *
 * [전자정부프레임워크와의 차이]
 * - 실제 전자정부프레임워크 1.0은 web.xml + applicationContext.xml로 구동됩니다.
 * - 이 프로젝트는 Spring Boot로 XML 설정을 최소화했지만 계층 구조는 동일합니다.
 *
 * [실행 방법]
 * mvn spring-boot:run
 * 또는 이 클래스를 IDE에서 Run
 *
 * [접속 URL]
 * http://localhost:8080/board/list
 */
@SpringBootApplication
public class EgovApplication {

    public static void main(String[] args) {
        SpringApplication.run(EgovApplication.class, args);
    }
}
