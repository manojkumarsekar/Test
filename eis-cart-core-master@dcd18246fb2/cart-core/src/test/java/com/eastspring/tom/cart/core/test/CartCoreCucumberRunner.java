package com.eastspring.tom.cart.core.test;

import cucumber.api.junit.Cucumber;
import org.junit.runner.Description;
import org.junit.runner.Runner;
import org.junit.runner.notification.RunNotifier;

import java.lang.annotation.Annotation;
import java.lang.reflect.Method;

public class CartCoreCucumberRunner extends Runner {
    private Class originalClass;
    private Cucumber cucumber;

    private static boolean skipFeatureTests = true;

    static {
        String testFeatures = System.getProperty("testFeatures");
        if(testFeatures != null && "true".equals(testFeatures)) {
            skipFeatureTests = false;
        }
    }

    public CartCoreCucumberRunner(Class clazzValue) throws Exception {
        this.originalClass = clazzValue;
        cucumber = new Cucumber(clazzValue);
    }

    @Override
    public Description getDescription() {
        return cucumber.getDescription();
    }

    private void runPredefinedMethods(Class annotation) throws Exception {
        if(skipFeatureTests) {
            System.out.println("===============");
            System.out.println("skipping");
            System.out.println("===============");
            return;
        }

        if(!annotation.isAnnotation()) {
            return;
        }

        Method[] methodList = this.originalClass.getMethods();
        for(Method method: methodList) {
            Annotation[] annotations = method.getAnnotations();
            for(Annotation item: annotations) {
                if(item.annotationType().equals(annotation)) {
                    method.invoke(null);
                    break;
                }
            }
        }
    }

    @Override
    public void run(RunNotifier runNotifier) {
        if(skipFeatureTests) {
            System.out.println("===============");
            System.out.println("skipping");
            System.out.println("===============");
            return;
        }

        try {
            runPredefinedMethods(BeforeSuite.class);
        } catch(Exception e) {
            throw new CartCoreCucumberException("Failed to run @BeforeSuite", e);
        }
        cucumber.run(runNotifier);
        try {
            runPredefinedMethods(AfterSuite.class);
        } catch(Exception e) {
            throw new CartCoreCucumberException("Failed to run @AfterSuite", e);
        }
    }
}
