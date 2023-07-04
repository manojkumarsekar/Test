package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.io.File;

@RunWith( SpringJUnit4ClassRunner.class )
@ContextConfiguration( classes = {CartCoreUtlConfig.class} )
public class ImageUtilRunIT {

    @Autowired
    private ImageUtl imageUtl;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(ImageUtilRunIT.class);
    }

    @Test
    public void compareDifferentImages() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Difference between images in percentage: 0.6640128501369692");
        final String baseImage = "target/test-classes/images/base_image1.jpeg";
        final String compareImage = "target/test-classes/images/compare_image1.jpeg";
        imageUtl.compareImages(new File(baseImage), new File(compareImage));
    }

    @Test
    public void compareSameImages() {
        final String baseImage = "target/test-classes/images/base_image1.jpeg";
        final String compareImage = "target/test-classes/images/base_image1.jpeg";
        imageUtl.compareImages(new File(baseImage), new File(compareImage));
    }
}
