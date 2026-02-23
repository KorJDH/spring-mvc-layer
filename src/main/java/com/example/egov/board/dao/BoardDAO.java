package com.example.egov.board.dao;

import com.example.egov.board.vo.BoardVO;

import java.util.List;

/**
 * 게시판 DAO 인터페이스 (Data Access Object)
 *
 * [전자정부프레임워크 패턴]
 * - DAO는 DB와 직접 통신하는 계층입니다.
 * - 인터페이스를 정의하고 Impl(구현체)을 별도로 만드는 것이 전통적인 패턴입니다.
 * - 메서드 이름 규칙: select/insert/update/delete + 대상
 *
 * [현대적 변화]
 * - MyBatis의 @Mapper 어노테이션을 사용하면 Impl 없이 인터페이스만으로 동작합니다.
 * - 이 프로젝트는 학습을 위해 전통적인 인터페이스 + Impl 패턴을 유지합니다.
 */
public interface BoardDAO {

    /**
     * 게시글 목록 조회 (페이징 + 검색 포함)
     * @param boardVO 검색조건 및 페이징 정보
     * @return 게시글 목록
     */
    List<BoardVO> selectBoardList(BoardVO boardVO);

    /**
     * 게시글 총 건수 조회
     * @param boardVO 검색조건
     * @return 총 게시글 수
     */
    int selectBoardTotalCount(BoardVO boardVO);

    /**
     * 게시글 상세 조회
     * @param boardNo 게시글 번호
     * @return 게시글 상세정보
     */
    BoardVO selectBoard(int boardNo);

    /**
     * 게시글 등록
     * @param boardVO 등록할 게시글 정보
     */
    void insertBoard(BoardVO boardVO);

    /**
     * 게시글 수정
     * @param boardVO 수정할 게시글 정보
     */
    void updateBoard(BoardVO boardVO);

    /**
     * 게시글 삭제
     * @param boardNo 삭제할 게시글 번호
     */
    void deleteBoard(int boardNo);

    /**
     * 조회수 증가
     * @param boardNo 게시글 번호
     */
    void updateBoardHit(int boardNo);
}
