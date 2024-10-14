package meow.dhru.sarah.meow;

import javax.servlet.jsp.tagext.*;
import javax.servlet.jsp.*;
import java.io.IOException;

public class ErrorDisplayTag extends SimpleTagSupport {
    private String message;

    public void setMessage(String message) {
        this.message = message;
    }

    public void doTag() throws JspException, IOException {
        JspWriter out = getJspContext().getOut();
        if (message != null) {
            out.print("<div class='error'>" + message + "</div>");
        }
    }
}
