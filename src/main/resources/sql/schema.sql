-- =========================================================
-- 게시판 테이블 생성
-- =========================================================

-- 기존 테이블이 있으면 삭제 (개발 편의용)
DROP TABLE IF EXISTS tb_board;

CREATE TABLE tb_board (
    board_no       INT          AUTO_INCREMENT PRIMARY KEY COMMENT '게시글 번호',
    board_title    VARCHAR(200) NOT NULL                   COMMENT '제목',
    board_content  TEXT         NOT NULL                   COMMENT '내용',
    board_writer   VARCHAR(50)  NOT NULL                   COMMENT '작성자',
    board_hit      INT          NOT NULL DEFAULT 0         COMMENT '조회수',
    board_regdate  DATETIME     NOT NULL DEFAULT NOW()     COMMENT '등록일시'
);
