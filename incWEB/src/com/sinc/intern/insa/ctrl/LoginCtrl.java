package com.sinc.intern.insa.ctrl;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.sinc.intern.insa.model.vo.UserDTO;
import com.sinc.intern.insa.service.UserService;
import com.sinc.intern.insa.service.UserServiceImpl;
import com.sinc.intern.util.Controller;
import com.sinc.intern.view.util.ModelAndView;

public class LoginCtrl implements Controller {
	
	// Dependency Injection (의존성 주입)
	private UserService service;
	public LoginCtrl() {
		service = new UserServiceImpl();
	}
	
	@Override
	public ModelAndView execute(HttpServletRequest request, HttpServletResponse response)
	throws ServletException, IOException {
		System.out.println("LoginCtrl excute");
		String id = request.getParameter("id");
		String pwd = request.getParameter("pwd");
		UserDTO dto = new UserDTO(id, pwd);
		Object user = service.select(dto);
		System.out.println("Ctrl result user : "+ user);
		ModelAndView mv = new ModelAndView();
		
		if (user != null) {
			//mv.setSend(true);
			//mv.setPath("ok.jsp");
			//mv.setPath("main.jsp");
			mv.setSend(false);
			mv.setPath("index.jsp");
			HttpSession session = request.getSession();
			session.setAttribute("loginSession", user);
		} else {
			mv.setSend(false);
			mv.setPath("error.jsp");
		}
		return mv;
	}
	
}
