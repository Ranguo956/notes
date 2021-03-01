package com.ran.web.controller;

import com.ran.domain.Permission;
import com.ran.page.PageResult;
import com.ran.query.PermissionQueryObject;
import com.ran.service.IPermissionService;
import com.ran.util.AjaxResult;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
public class PermissionController {

    @Autowired
    private IPermissionService permissionService;

    @RequestMapping("/permission_list")
    @ResponseBody
    public PageResult list(PermissionQueryObject queryObject) {
        return permissionService.queryForPage(queryObject);
    }

    @RequestMapping("/permission_queryByRid")
    @ResponseBody
    public PageResult queryByRid(PermissionQueryObject queryObject) {
        return permissionService.queryForPage(queryObject);
    }

    @RequestMapping("/permission")
    public String index() {
        return "permission";
    }

    @RequestMapping("/permission_save")
    @ResponseBody
    public AjaxResult save(Permission permission) {

        AjaxResult result = null;
        try {
            permissionService.insert(permission);
            result = new AjaxResult("保存成功", true);
        } catch (Exception e) {
            result = new AjaxResult("保存异常，请联系管理员", false);
        }
        return result;
    }

    @RequestMapping("/permission_update")
    @ResponseBody
    public AjaxResult update(Permission permission) {

        AjaxResult result = null;
        try {
            permissionService.updateByPrimaryKey(permission);
            result = new AjaxResult("更新成功", true);
        } catch (Exception e) {
            result = new AjaxResult("更新异常，请联系管理员", false);
        }
        return result;
    }

    @RequestMapping("/permission_delete")
    @ResponseBody
    public AjaxResult delete(Long id) {

        AjaxResult result = null;
        try {
            permissionService.deleteByPrimaryKey(id);
            result = new AjaxResult("删除功能未开发", true);
        } catch (Exception e) {
            result = new AjaxResult("删除异常，请联系管理员", false);
        }
        return result;
    }
}
