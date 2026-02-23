package com.example.egov.board.vo;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

/**
 * 게시판 VO (Value Object)
 *
 * [전자정부프레임워크 패턴]
 * - VO는 데이터를 담는 순수한 그릇(객체)입니다.
 * - DB 테이블의 컬럼과 1:1로 매핑됩니다.
 * - getter/setter만 존재하며 비즈니스 로직은 없습니다.
 *
 * [실무 팁]
 * - 전자정부프레임워크에서는 VO와 DTO를 구분하지 않고 VO로 통일해서 씁니다.
 * - 현대적인 프로젝트에서는 DTO(Data Transfer Object)와 분리하기도 합니다.
 */
@Getter
@Setter
@ToString
public class BoardVO {

    /** 게시글 번호 (Primary Key, Auto Increment) */
    private int boardNo;

    /** 게시글 제목 */
    private String boardTitle;

    /** 게시글 내용 */
    private String boardContent;

    /** 작성자 */
    private String boardWriter;

    /** 조회수 */
    private int boardHit;

    /** 등록일시 */
    private String boardRegdate;

    // -----------------------------------------------
    // 검색 조건 (페이징, 검색)
    // 실무에서는 별도 SearchVO로 분리하기도 함
    // -----------------------------------------------

    /** 검색 조건 (제목, 내용, 작성자 등) */
    private String searchCondition;

    /** 검색어 */
    private String searchKeyword;

    /** 페이지 번호 */
    private int pageIndex = 1;

    /** 페이지당 게시글 수 */
    private int pageUnit = 10;

    /** 쿼리 offset 계산값 */
    public int getFirstIndex() {
        return (pageIndex - 1) * pageUnit;
    }
}
