package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.utl.DataTableUtil;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.ScenarioUtil;
import io.cucumber.datatable.DataTable;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.*;
import java.util.stream.Collectors;

public class DataTableSvc {

    private static final Logger LOGGER = LoggerFactory.getLogger(DataTableSvc.class);
    public static final String FILE_PREFIX = "file:";
    public static final String LINE_SEPARATOR = "\\r?\\n";

    @Autowired
    private DataTableUtil dataTableUtil;

    @Autowired
    private WorkspaceDirSvc workspaceDirSvc;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private ScenarioUtil scenarioUtil;

    @Autowired
    private StateSvc stateSvc;

    public List<String> getFirstColsAsList(final DataTable dataTable) {
        List<String> list = dataTableUtil.getFirstColsAsList(dataTable);
        if (list.size() == 1 && list.get(0).startsWith(FILE_PREFIX)) {
            final String filename = this.resolveFileName(list);
            LOGGER.debug("filename [{}] identified to read data", filename);
            List<String> result = Arrays.stream(fileDirUtil.readFileToString(filename).split(LINE_SEPARATOR))
                    .collect(Collectors.toList())
                    .stream()
                    .map(String::trim)
                    .collect(Collectors.toList());
            scenarioUtil.write("No. of rows in file " + result.size() + ", File Contents:\n" + result.toString());
            return result;
        }
        return list;
    }

    public LinkedHashMap<String, String> getTwoColumnAsOrderedMap(DataTable dataTable) {
        return new LinkedHashMap<>(getTwoColumnAsMap(dataTable));
    }

    public Map<String, String> getTwoColumnAsMap(DataTable dataTable) {
        List<String> list = dataTableUtil.getFirstColsAsList(dataTable);

        if (list.size() == 1 && list.get(0).startsWith(FILE_PREFIX)) {
            final String filename = this.resolveFileName(list);
            LOGGER.debug("filename [{}] identified to read data", filename);
            List<String> data = Arrays.stream(fileDirUtil.readFileToString(filename).split(LINE_SEPARATOR))
                    .collect(Collectors.toList())
                    .stream()
                    .map(String::trim)
                    .collect(Collectors.toList());

            HashMap<String, String> result = new HashMap<>();

            for (String line : data) {
                String[] keyValue = line.split(",");
                result.put(keyValue[0], keyValue[1]);
            }
            scenarioUtil.write("File Contents:\n" + result.toString());
            return result;
        }
        return dataTableUtil.getTwoColumnAsMap(dataTable);
    }

    private String resolveFileName(final List<String> columnList) {
        return stateSvc.expandVar(workspaceDirSvc.normalize(columnList.get(0).replaceFirst(FILE_PREFIX, "").trim()));
    }


}
