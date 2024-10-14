package meow.dhru.sarah.meow;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.SimpleTagSupport;
import javax.servlet.jsp.PageContext;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class UserDisplayTag extends SimpleTagSupport {

    @Override
    public void doTag() throws JspException, IOException {
        try {
            // Cast JspContext to PageContext to access session
            PageContext pageContext = (PageContext) getJspContext();
            HttpSession session = pageContext.getSession();

            // Retrieve the username from the session
            String username = (String) session.getAttribute("username");

            // Write the username to the response
            JspWriter out = getJspContext().getOut();
            if (username != null) {
                out.write(username);
            } else {
                out.write("Guest");
            }
        } catch (Exception e) {
            throw new JspException("Error in UserDisplayTag", e);
        }
    }
}
