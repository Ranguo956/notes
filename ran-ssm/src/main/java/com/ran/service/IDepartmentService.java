package com.ran.service;

import com.ran.domain.Department;
import com.ran.page.PageResult;
import com.ran.query.DepartmentQueryObject;

import java.util.List;

public interface IDepartmentService {
    int deleteByPrimaryKey(Long id);

    int insert(Department record);

    Department selectByPrimaryKey(Long id);

    List<Department> selectAll();

    int updateByPrimaryKey(Department record);

    List<Department> queryForEmp();

    PageResult queryForPage(DepartmentQueryObject queryObject);

    int updateState(Long id);

//    Department getDepartmentForLogin(String username, String password);
//
//    PageResult queryForPage(DepartmentQueryObject queryObject);
}
