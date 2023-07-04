package tomcart.glue;

import cucumber.api.java8.En;
import cucumber.api.java8.StepdefBody;

/**
 * The type Json custom formatter steps def.
 * These are dummy methods to test Custom Json Formatting + Html reports generation scenarios
 */
public class JsonCustomFormatterStepsDef implements En {

    /**
     * Instantiates a new Json custom formatter steps def.
     */
    public JsonCustomFormatterStepsDef() {
        Given("Assign {string} to {string}", (String value, String variable) -> System.out.println(value + "->" + variable));
        Given("Assign {int} to {string}", (Integer value, String variable) -> System.out.println(value + "->" + variable));
        Given("Expand var1 {string} var2 {string} and var3 {string}", (String str1, String str2, String str3) -> System.out.println(str1 + " " + str2 + " " + str3 ));
        Given("Expand var1 {string} var2 {string}", (String str1, String str2) -> System.out.println(str1 + " " + str2));
        Given("Expand var1 {string}", (StepdefBody.A1<String>) System.out::println);
        Given("Expand below cells", (io.cucumber.datatable.DataTable dataTable) -> System.out.println("cells"));
        Given("I Expand below doc_string", (StepdefBody.A1<String>) System.out::println);

    }
}
