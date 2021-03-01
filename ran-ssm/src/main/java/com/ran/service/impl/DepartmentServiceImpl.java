package com.ran.service.impl;

import com.ran.domain.Department;
import com.ran.domain.Employee;
import com.ran.mapper.DepartmentMapper;
import com.ran.page.PageResult;
import com.ran.query.DepartmentQueryObject;
import com.ran.service.IDepartmentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;

/**
 * 由于还需要考虑外键，部门表只做查询和新增
 */
@Service
public class DepartmentServiceImpl implements IDepartmentService {

    @Autowired
    private DepartmentMapper departmentMapper;

    @Override
    public int deleteByPrimaryKey(Long id) {
        return 0;
    }

    @Override
    public int insert(Department record) {
        return departmentMapper.insert(record);
    }

    @Override
    public Department selectByPrimaryKey(Long id) {
        return null;
    }

    @Override
    public List<Department> selectAll() {
        return null;
    }

    @Override
    public int updateByPrimaryKey(Department record) {
        return 0;
    }

    @Override
    public List<Department> queryForEmp() {
        return departmentMapper.queryForEmp();
    }

    @Override
    public PageResult queryForPage(DepartmentQueryObject queryObject) {
        // 查询总记录数
        Long count = departmentMapper.queryForPageCount(queryObject);
        if (count == 0) {
            return new PageResult(0, Collections.emptyList());
        }

        List<Employee> result = departmentMapper.queryForPage(queryObject);
        return new PageResult(count.intValue(), result);
    }

    @Override
    public int updateState(Long id) {
        return 0;
    }

}
