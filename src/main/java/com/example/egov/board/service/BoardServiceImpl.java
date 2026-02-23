package com.example.egov.board.service;

import com.example.egov.board.dao.BoardDAO;
import com.example.egov.board.vo.BoardVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 게시판 Service 구현체
 *
 * [전자정부프레임워크 패턴]
 * - @Service: Spring이 이 클래스를 "비즈니스 로직 계층"으로 인식합니다.
 * - @Transactional: DB 작업을 하나의 단위로 묶습니다. 실패 시 자동 롤백.
 *
 * [계층 구조]
 * Controller → ServiceImpl → DAO → DB
 *              (여기서 비즈니스 로직 처리)
 *
 * [트랜잭션 전략]
 * - 조회: readOnly=true (성능 최적화)
 * - 등록/수정/삭제: 기본 트랜잭션 (실패 시 롤백)
 */
@Service("boardService")
public class BoardServiceImpl implements BoardService {

    @Autowired
    private BoardDAO boardDAO;

    @Override
    @Transactional(readOnly = true)
    public List<BoardVO> selectBoardList(BoardVO boardVO) {
        return boardDAO.selectBoardList(boardVO);
    }

    @Override
    @Transactional(readOnly = true)
    public int selectBoardTotalCount(BoardVO boardVO) {
        return boardDAO.selectBoardTotalCount(boardVO);
    }

    @Override
    @Transactional
    public BoardVO selectBoard(int boardNo) {
        // 조회수 증가 후 상세 조회 (하나의 트랜잭션으로 처리)
        boardDAO.updateBoardHit(boardNo);
        return boardDAO.selectBoard(boardNo);
    }

    @Override
    @Transactional
    public void insertBoard(BoardVO boardVO) {
        boardDAO.insertBoard(boardVO);
    }

    @Override
    @Transactional
    public void updateBoard(BoardVO boardVO) {
        boardDAO.updateBoard(boardVO);
    }

    @Override
    @Transactional
    public void deleteBoard(int boardNo) {
        boardDAO.deleteBoard(boardNo);
    }
}
