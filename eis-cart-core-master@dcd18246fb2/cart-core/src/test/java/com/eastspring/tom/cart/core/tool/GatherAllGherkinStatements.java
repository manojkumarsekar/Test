package com.eastspring.tom.cart.core.tool;

import com.eastspring.tom.cart.cst.EncodingConstants;
import org.apache.commons.io.FileUtils;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

public class GatherAllGherkinStatements {

    public static final String BEGINNING_SIGNATURE_1 = "Given(\"^";
    public static final String BEGINNING_SIGNATURE_2 = "When(\"^";
    public static final String BEGINNING_SIGNATURE_3 = "Then(\"^";
    public static final String END_SIGNATURE = "->";

    public static void main(String[] args) throws Exception {
        String baseDir = "c:/tomwork/cart-core/src/main/java";
        List<File> stepsDefList = FileUtils.listFiles(new File(baseDir), new String[]{"java"}, true).stream().filter((File x) -> x != null && x.getAbsolutePath().endsWith("StepsDef.java")).collect(Collectors.toList());

        List<String> beginningSignatures = new ArrayList<String>() {{
            add(BEGINNING_SIGNATURE_1);
            add(BEGINNING_SIGNATURE_2);
            add(BEGINNING_SIGNATURE_3);
        }};
        List<FragmentThis> fragments = new ArrayList<>();

        for(File stepsDef: stepsDefList) {

            String fileContent = FileUtils.readFileToString(stepsDef, EncodingConstants.UTF_8);

            for(String beginningSignature: beginningSignatures) {
                int beginSignatureLen = beginningSignature.length();
                int endSignatureLen = END_SIGNATURE.length();
                int locNext = fileContent.indexOf(beginningSignature);
                while (locNext > 0) {
                    int startIdx = locNext;
                    locNext = fileContent.indexOf(END_SIGNATURE, startIdx + beginSignatureLen);
                    int endIdx;
                    if (locNext > 0) {
                        endIdx = locNext - endSignatureLen + 1;
                        String fragmentLine = fileContent.substring(startIdx + beginSignatureLen, endIdx);
                        FragmentThis fragment = new FragmentThis(stepsDef.getAbsolutePath(), fragmentLine);
                        System.out.println(fragmentLine);
                        fragments.add(fragment);
                    } else {
                        break;
                    }
                    locNext = fileContent.indexOf(beginningSignature, endIdx + endSignatureLen);
                }
            }

        }

        for(FragmentThis fragment: fragments) {
            String statement = processFragment(fragment.getLine());
            System.out.println("[" + statement + "]");
        }
    }

    private static String processFragment(String fragment) {
        String variableSignature = "\\\"([^\\\"]*)\\\"";
        int variableSignatureLen = variableSignature.length();
        StringBuilder sb = new StringBuilder();
        int prevPos = 0;
        int varCounter = 1;
        int varLocNext = fragment.indexOf(variableSignature);
        while(varLocNext > 0) {
            int startIdx = varLocNext;
            int endIdx = varLocNext + variableSignatureLen;
            sb.append(fragment.substring(prevPos, startIdx));
            sb.append("\"$var").append(varCounter).append("\"");
            varCounter++;
            prevPos = endIdx;
            varLocNext = fragment.indexOf(variableSignature, prevPos);
        }
        sb.append(fragment.substring(prevPos));

        return sb.toString().replace("\n", "").replace("\r", "").replace("$\",", "");
    }
}
