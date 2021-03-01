package com.ran.web.controller;

import com.ran.domain.Menu;
import com.ran.util.UserContext;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;

@Controller
public class IndexController {

    @RequestMapping("/index")
    public String index() {
        return "index";
    }

    @RequestMapping("/queryForMenu")
    @ResponseBody
    public List<Menu> queryForMenu() {
        // 从session中获取当前用户对应的菜单（用户角色不同菜单也不同）
        return (List<Menu>) UserContext.get().getSession().getAttribute(UserContext.MENU_IN_SESSION);
    }

}
