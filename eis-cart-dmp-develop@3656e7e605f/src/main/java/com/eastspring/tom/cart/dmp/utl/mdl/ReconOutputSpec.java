package com.eastspring.tom.cart.dmp.utl.mdl;

import lombok.*;

import java.util.List;
import java.util.Objects;

@Getter
@Setter
@AllArgsConstructor
@RequiredArgsConstructor
@EqualsAndHashCode
public class ReconOutputSpec {

    private @NonNull Boolean isMatch;
    private @NonNull List<String> exceptions;
    private String errorMessage;

}
