package com.ran.service;

import com.ran.domain.Log;

import java.util.List;

public interface ILogService {
    int deleteByPrimaryKey(Long id);

    int insert(Log record);

    Log selectByPrimaryKey(Long id);

    List<Log> selectAll();

    int updateByPrimaryKey(Log record);

}
