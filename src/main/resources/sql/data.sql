-- =========================================================
-- 샘플 데이터 (학습용)
-- =========================================================

INSERT INTO tb_board (board_title, board_content, board_writer) VALUES
('전자정부프레임워크 소개', '전자정부프레임워크는 공공 IT 서비스의 표준 개발 환경입니다.', '관리자'),
('Spring MVC 패턴 설명', 'Controller - Service - DAO - VO 각 계층의 역할을 학습합니다.', '강사'),
('MyBatis 사용법', 'MyBatis는 SQL을 XML로 관리하는 SQL Mapper 프레임워크입니다.', '강사'),
('VO vs DTO 차이점', 'VO(Value Object)와 DTO(Data Transfer Object)의 차이를 알아봅니다.', '학생'),
('트랜잭션이란?', '@Transactional을 사용하면 DB 작업을 하나의 단위로 묶을 수 있습니다.', '강사');
