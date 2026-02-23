package com.example.egov.board.dao;

import com.example.egov.board.vo.BoardVO;
import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * 게시판 DAO 구현체
 *
 * [전자정부프레임워크 패턴]
 * - @Repository: Spring이 이 클래스를 "데이터 접근 계층"으로 인식합니다.
 * - SqlSession: MyBatis를 통해 SQL을 실행하는 핵심 객체입니다.
 * - namespace: Mapper XML의 namespace + SQL id로 쿼리를 찾아 실행합니다.
 *
 * [실행 흐름]
 * Controller → Service → DAOImpl → SqlSession → Mapper XML → DB
 *
 * [네이밍 규칙]
 * NAMESPACE = Mapper XML의 namespace 속성값과 동일해야 합니다.
 */
@Repository("boardDAO")
public class BoardDAOImpl implements BoardDAO {

    // Mapper XML의 namespace와 일치시킵니다
    private static final String NAMESPACE = "com.example.egov.board.mapper.BoardMapper";

    @Autowired
    private SqlSession sqlSession;

    @Override
    public List<BoardVO> selectBoardList(BoardVO boardVO) {
        // sqlSession.selectList("namespace.sqlId", 파라미터)
        return sqlSession.selectList(NAMESPACE + ".selectBoardList", boardVO);
    }

    @Override
    public int selectBoardTotalCount(BoardVO boardVO) {
        return sqlSession.selectOne(NAMESPACE + ".selectBoardTotalCount", boardVO);
    }

    @Override
    public BoardVO selectBoard(int boardNo) {
        return sqlSession.selectOne(NAMESPACE + ".selectBoard", boardNo);
    }

    @Override
    public void insertBoard(BoardVO boardVO) {
        // sqlSession.insert("namespace.sqlId", 파라미터)
        sqlSession.insert(NAMESPACE + ".insertBoard", boardVO);
    }

    @Override
    public void updateBoard(BoardVO boardVO) {
        sqlSession.update(NAMESPACE + ".updateBoard", boardVO);
    }

    @Override
    public void deleteBoard(int boardNo) {
        sqlSession.delete(NAMESPACE + ".deleteBoard", boardNo);
    }

    @Override
    public void updateBoardHit(int boardNo) {
        sqlSession.update(NAMESPACE + ".updateBoardHit", boardNo);
    }
}
