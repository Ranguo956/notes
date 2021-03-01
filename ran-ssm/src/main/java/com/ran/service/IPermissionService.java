package com.ran.service;

import com.ran.domain.Permission;
import com.ran.page.PageResult;
import com.ran.query.QueryObject;

import java.util.List;

public interface IPermissionService {
    int deleteByPrimaryKey(Long id);

    int insert(Permission record);

    Permission selectByPrimaryKey(Long id);

    List<Permission> selectAll();

    int updateByPrimaryKey(Permission record);

    PageResult queryForPage(QueryObject queryObject);

    List<String> queryResourceByEid(Long id);
}
