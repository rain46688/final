package com.kh.john.alarm.model.service;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.kh.john.alarm.model.dao.AlarmDao;

@Service
public class AlarmServiceImpl implements AlarmService {

	@Autowired
	private AlarmDao dao;

	@Autowired
	private SqlSessionTemplate session;

}
