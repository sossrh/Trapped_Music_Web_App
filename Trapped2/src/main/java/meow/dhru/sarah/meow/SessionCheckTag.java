package meow.dhru.sarah.meow;

import javax.servlet.jsp.tagext.*;
import javax.servlet.jsp.*;
import javax.servlet.http.HttpSession;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class SessionCheckTag extends SimpleTagSupport {
    public void doTag() throws JspException, IOException {
        // Cast JspContext to PageContext to access HttpServletRequest
        PageContext pageContext = (PageContext) getJspContext();
        HttpServletRequest request = (HttpServletRequest) pageContext.getRequest();
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("username") == null) {
            JspWriter out = getJspContext().getOut();
            out.print("Session invalid. Please log in.");
            
            // Cast JspContext to PageContext to access HttpServletResponse
            HttpServletResponse response = (HttpServletResponse) pageContext.getResponse();
            try {
				request.getRequestDispatcher("login.jsp").forward(request, response);
			} catch (ServletException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
        }
    }
}
