package com.kh.john.member.model.dao;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;

import com.kh.john.board.model.vo.Board;
import com.kh.john.member.model.vo.License;
import com.kh.john.member.model.vo.LikeDislike;
import com.kh.john.member.model.vo.Member;
import com.kh.john.report.model.vo.Report;

public interface MemberDao {

	List<Map<String, Object>> selectMember(SqlSessionTemplate session);

	Member selectMemberById(SqlSessionTemplate session, Member member);
	Member selectMemberById(SqlSessionTemplate session, Map param);

	Member nickDuplicate(SqlSessionTemplate session, Member member);

	Member phoneDuplicate(SqlSessionTemplate session, Member member);
	
	int signUpEnd(SqlSessionTemplate session, Member member);
	int signUpExpert(SqlSessionTemplate session, License l);

	Member findId(SqlSessionTemplate session, Member member);

	Member findPw(SqlSessionTemplate session, Member member);

	int tempPw(SqlSessionTemplate session, Member member);

	int updatePw(SqlSessionTemplate session, Member member);

	int updateNick(SqlSessionTemplate session, Member member);

	int updatePic(SqlSessionTemplate session, Member member);

	int updatePhone(SqlSessionTemplate session, Member member);

	List<Board> myBoard(SqlSessionTemplate session, int cPage, int numPerPage, int usid);

	int myBoardCount(SqlSessionTemplate session,int usid);

	Board searchBoard(SqlSessionTemplate session, Board board);

	List<Board> liked(SqlSessionTemplate session, int cPage, int numPerPage, int usid);

	int likedCount(SqlSessionTemplate session, int usid);

	List<Report> myReport(SqlSessionTemplate session, int cPage, int numPerPage, int usid);

	int myReportCount(SqlSessionTemplate session, int usid);

	Report searchReport(SqlSessionTemplate session, Report report);

	int updateMemberClass(SqlSessionTemplate session, Member member);

	int applyExpert(SqlSessionTemplate session, License l);

}
