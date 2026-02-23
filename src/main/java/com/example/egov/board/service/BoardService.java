package com.example.egov.board.service;

import com.example.egov.board.vo.BoardVO;

import java.util.List;

/**
 * 게시판 Service 인터페이스
 *
 * [전자정부프레임워크 패턴]
 * - Service 계층은 비즈니스 로직을 담당합니다.
 * - Controller는 요청/응답만 처리하고, 실제 업무 로직은 Service에 있습니다.
 * - 트랜잭션(@Transactional)은 Service 계층에서 관리합니다.
 *
 * [왜 인터페이스를 만드는가?]
 * 1. 테스트 시 Mock 객체로 쉽게 교체 가능
 * 2. AOP(트랜잭션, 로깅) 적용이 용이
 * 3. 다형성 활용 (구현체를 바꿔도 Controller 코드는 불변)
 */
public interface BoardService {

    /**
     * 게시글 목록 조회
     */
    List<BoardVO> selectBoardList(BoardVO boardVO);

    /**
     * 게시글 총 건수
     */
    int selectBoardTotalCount(BoardVO boardVO);

    /**
     * 게시글 상세 조회 (조회수 증가 포함)
     */
    BoardVO selectBoard(int boardNo);

    /**
     * 게시글 등록
     */
    void insertBoard(BoardVO boardVO);

    /**
     * 게시글 수정
     */
    void updateBoard(BoardVO boardVO);

    /**
     * 게시글 삭제
     */
    void deleteBoard(int boardNo);
}
