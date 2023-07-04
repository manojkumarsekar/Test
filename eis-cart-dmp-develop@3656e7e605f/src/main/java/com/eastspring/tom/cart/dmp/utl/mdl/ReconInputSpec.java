package com.eastspring.tom.cart.dmp.utl.mdl;

import lombok.Builder;
import lombok.Getter;

@Builder
@Getter
public class ReconInputSpec {

    private String file1;
    private String file2;
    private boolean ignoreRowCount;
    private boolean lookForRecords;
    private boolean considerOrder;
    private boolean ignoreHeader;

}
