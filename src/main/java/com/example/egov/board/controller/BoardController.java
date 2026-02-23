package com.example.egov.board.controller;

import com.example.egov.board.service.BoardService;
import com.example.egov.board.vo.BoardVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

/**
 * 게시판 Controller
 *
 * [전자정부프레임워크 패턴]
 * - @Controller: Spring MVC Controller. View(JSP)를 반환합니다.
 * - ModelMap: View에 데이터를 전달하는 객체 (= Model, ModelAndView와 동일 역할)
 * - 반환값(String): View 이름 (ViewResolver가 실제 JSP 경로로 변환)
 *
 * [Controller의 역할]
 * 1. HTTP 요청을 받아 파라미터 추출
 * 2. Service 호출 (비즈니스 로직은 직접 작성 X)
 * 3. 결과를 Model에 담아 View로 전달
 *
 * [URL 설계]
 * GET  /board/list       → 게시글 목록
 * GET  /board/view       → 게시글 상세
 * GET  /board/writeForm  → 등록 폼
 * POST /board/write      → 게시글 등록 처리
 * GET  /board/updateForm → 수정 폼
 * POST /board/update     → 게시글 수정 처리
 * POST /board/delete     → 게시글 삭제 처리
 */
@Controller
@RequestMapping("/board")
public class BoardController {

    @Autowired
    private BoardService boardService;

    // --------------------------------------------------------
    // 게시글 목록 조회
    // --------------------------------------------------------
    @GetMapping("/list")
    public String selectBoardList(BoardVO boardVO, ModelMap model) {

        // 1. 총 게시글 수 조회 (페이징 계산용)
        int totalCount = boardService.selectBoardTotalCount(boardVO);

        // 2. 게시글 목록 조회
        List<BoardVO> boardList = boardService.selectBoardList(boardVO);

        // 3. View에 데이터 전달
        model.addAttribute("totalCount", totalCount);
        model.addAttribute("boardList", boardList);
        model.addAttribute("boardVO", boardVO);  // 검색 조건 유지를 위해

        // "board/list" → /WEB-INF/views/board/list.jsp 로 변환됨
        return "board/list";
    }

    // --------------------------------------------------------
    // 게시글 상세 조회
    // --------------------------------------------------------
    @GetMapping("/view")
    public String selectBoard(@RequestParam int boardNo, ModelMap model) {

        // Service에서 조회수 증가 + 상세 조회를 한 번에 처리
        BoardVO board = boardService.selectBoard(boardNo);

        model.addAttribute("board", board);

        return "board/view";
    }

    // --------------------------------------------------------
    // 게시글 등록 폼
    // --------------------------------------------------------
    @GetMapping("/writeForm")
    public String writeForm() {
        // 빈 폼을 보여줌 (데이터 전달 필요 없음)
        return "board/writeForm";
    }

    // --------------------------------------------------------
    // 게시글 등록 처리
    // --------------------------------------------------------
    @PostMapping("/write")
    public String insertBoard(BoardVO boardVO) {

        boardService.insertBoard(boardVO);

        // 등록 후 목록으로 이동 (redirect: PRG 패턴)
        // PRG = Post-Redirect-Get: 새로고침 시 중복 등록 방지
        return "redirect:/board/list";
    }

    // --------------------------------------------------------
    // 게시글 수정 폼
    // --------------------------------------------------------
    @GetMapping("/updateForm")
    public String updateForm(@RequestParam int boardNo, ModelMap model) {

        BoardVO board = boardService.selectBoard(boardNo);
        model.addAttribute("board", board);

        return "board/updateForm";
    }

    // --------------------------------------------------------
    // 게시글 수정 처리
    // --------------------------------------------------------
    @PostMapping("/update")
    public String updateBoard(BoardVO boardVO) {

        boardService.updateBoard(boardVO);

        // 수정 후 상세 페이지로 이동
        return "redirect:/board/view?boardNo=" + boardVO.getBoardNo();
    }

    // --------------------------------------------------------
    // 게시글 삭제 처리
    // --------------------------------------------------------
    @PostMapping("/delete")
    public String deleteBoard(@RequestParam int boardNo) {

        boardService.deleteBoard(boardNo);

        return "redirect:/board/list";
    }
}
