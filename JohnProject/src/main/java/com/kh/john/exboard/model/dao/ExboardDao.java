package com.kh.john.exboard.model.dao;

import java.util.List;

import org.mybatis.spring.SqlSessionTemplate;

import com.kh.john.exboard.model.vo.SessionVo;
import com.kh.john.member.model.vo.Member;

public interface ExboardDao {

	List<Member> selectExpert(SqlSessionTemplate session) throws Exception;

	Member selectExpertMem(SqlSessionTemplate session, String no) throws Exception;

	int insertExpertMemRequest(SqlSessionTemplate session, String no, SessionVo mem) throws Exception;

}
