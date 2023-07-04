package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

public class WorkspaceDirSvc {
    private static final Logger LOGGER = LoggerFactory.getLogger(WorkspaceDirSvc.class);

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @Autowired
    private FileDirUtil fileDirUtil;

    public String normalize(String path) {
        String workspaceBaseDir = workspaceUtil.getBaseDir();
        LOGGER.debug("workspaceBaseDir: [{}]", workspaceBaseDir);
        LOGGER.debug("path: [{}]", path);
        String result = fileDirUtil.addPrefixIfNotAbsolute(path, workspaceBaseDir);
        LOGGER.debug("normalize: path1: [{}]", result);
        return result;
    }
}
