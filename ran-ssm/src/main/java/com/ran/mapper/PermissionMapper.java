package com.ran.mapper;

import com.ran.domain.Permission;
import com.ran.query.QueryObject;

import java.util.List;

public interface PermissionMapper {
    int deleteByPrimaryKey(Long id);

    int insert(Permission record);

    Permission selectByPrimaryKey(Long id);

    List<Permission> selectAll();

    int updateByPrimaryKey(Permission record);

    Long queryForPageCount(QueryObject queryObject);

    List<Permission> queryForPage(QueryObject queryObject);

    List<String> queryResourceByEid(Long eid);
}