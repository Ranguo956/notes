package com.ran.mapper;

import com.ran.domain.Role;
import com.ran.query.QueryObject;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface RoleMapper {
    int deleteByPrimaryKey(Long id);

    int insert(Role record);

    Role selectByPrimaryKey(Long id);

    List<Role> selectAll();

    int updateByPrimaryKey(Role record);

    int insertRelation(@Param("rid") Long rid, @Param("pid") Long pid);

    Long queryForPageCount(QueryObject queryObject);

    List<Role> queryForPage(QueryObject queryObject);

    int deletePermissionByRid(Long id);
}
