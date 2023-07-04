package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.steps.CartCoreStepsSvcUtlTestConfig;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreStepsSvcUtlTestConfig.class})
public class MathUtilRunIT {
    @Autowired
    private MathUtil mathUtil;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(MathUtilRunIT.class);
    }

    @Test
    public void testComputeExpressionForValidExp() {
        String input1 = mathUtil.computeExpression("Math.round(123.86)");
        String input2 = mathUtil.computeExpression("Math.round(11 + (Math.exp(2.010635 + Math.sin(Math.PI/2)*3) + 50) / 2)");

        Assert.assertEquals("Testing Math expression", input1, "124.0");
        Assert.assertEquals("Testing Math expression", input2, "111.0");
    }

    @Test
    public void testComputeExpressionForInvalidExp() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Expression [invalid_expression] entered is invalid");
        mathUtil.computeExpression("invalid_expression");
    }

    @Test
    public void testComputeExpressionForEmptyExp() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Expression [] entered is invalid");
        mathUtil.computeExpression("");
    }

}
