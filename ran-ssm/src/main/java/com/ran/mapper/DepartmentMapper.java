package com.ran.mapper;

import com.ran.domain.Department;
import com.ran.domain.Employee;
import com.ran.query.DepartmentQueryObject;

import java.util.List;

public interface DepartmentMapper {
    int deleteByPrimaryKey(Long id);

    int insert(Department record);

    Department selectByPrimaryKey(Long id);

    List<Department> selectAll();

    int updateByPrimaryKey(Department record);

    List<Department> queryForEmp();

    Long queryForPageCount(DepartmentQueryObject queryObject);

    List<Employee> queryForPage(DepartmentQueryObject queryObject);
}