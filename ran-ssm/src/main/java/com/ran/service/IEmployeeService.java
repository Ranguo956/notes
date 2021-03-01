package com.ran.service;

import com.ran.domain.Employee;
import com.ran.page.PageResult;
import com.ran.query.EmployeeQueryObject;

import java.util.List;

public interface IEmployeeService {
    int deleteByPrimaryKey(Long id);

    int insert(Employee record);

    Employee selectByPrimaryKey(Long id);

    List<Employee> selectAll();

    int updateByPrimaryKey(Employee record);

    Employee getEmployeeForLogin(String username, String password);

    PageResult queryForPage(EmployeeQueryObject queryObject);

    int updateState(Long id);

    List<Long> queryRoleByEid(Long eid);
}
