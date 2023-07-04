#eisdev-4693 : Compare Json Workflow uses the map os gso relation to identify its lookup key. Look up key should be defined for all the GSO which has UI suppport.

@dmp_regression_unittest
@post_deployment_check
@eisdev_6367
Feature: 001 | Misc | Lookup field mapping for GSO Relations

  Expect all GSO relation are defined with lookup field
  Add this query created to identify the missing relation into regression suite.
  In case, any new relation is defined and is missed defining the lookup field, regression suite would catch it.
  This would ensure CompareJson functionality works as expected.

  Scenario: Data verification in GC for Missing Relation
  Expect all GSO relation are defined with lookup field

    Given I expect value of column "missing_lookupfield_count" in the below SQL query equals to "0":
    """
    SELECT count(*) as missing_lookupfield_count
    FROM   (SELECT BDEF_NAME.bus_entity_data_nme gso_name,
               Nvl((SELECT fld_label_txt FROM ft_be_dgdp WHERE  berl_oid = BERL.berl_oid), BERL.rel_nme) AS REL_NAME_DSP_TXT,
               REL_BDEF.bus_entity_data_nme rel_gso_name
        FROM   ft_be_berl BERL,
               (SELECT Substr(Sys_connect_by_path(bdef_oid, '#'), 2, 16) GSO_NAME_BDEF_OID, BDEF.*
                 FROM   ft_be_bdef BDEF
                 CONNECT BY PRIOR prnt_bdef_oid = bdef_oid) BDEF,
               ft_be_bdef REL_BDEF,
               ft_be_bdef BDEF_NAME
        WHERE  BERL.rel_bdef_oid = REL_BDEF.bdef_oid
               AND BERL.bdef_oid = BDEF.bdef_oid
               AND BDEF.gso_name_bdef_oid = BDEF_NAME.bdef_oid) gso_rel_gso,
       (SELECT DISTINCT( DGDF.data_grp_nme || '.' || BFDF.bus_entity_fld_nme )
                       datagroup_lookupkey_rel_nme,
                       BERL.rel_nme rel_nme
        FROM   ft_be_berl BERL,
               ft_be_dgdp DGDP1,
               ft_be_dgdf DGDF,
               ft_be_bfdf BFDF,
               ft_be_dgdp DGDP2
        WHERE  BERL.dgdp_oid = DGDP1.dgdp_oid
               AND DGDP1.prnt_dgdf_oid = DGDF.dgdf_oid
               AND DGDP1.bfdf_oid = BFDF.bfdf_oid
               AND BERL.berl_oid = DGDP2.berl_oid) lookupkey_rel_nme,
       (SELECT DISTINCT( DGDF.data_grp_nme || '.' || BFDF.bus_entity_fld_nme )
                       datagroup_lookupkey_fld_label_txt,
                       DGDP2.fld_label_txt fld_label_txt
        FROM   ft_be_berl BERL,
               ft_be_dgdp DGDP1,
               ft_be_dgdf DGDF,
               ft_be_bfdf BFDF,
               ft_be_dgdp DGDP2
        WHERE  BERL.dgdp_oid = DGDP1.dgdp_oid
               AND DGDP1.prnt_dgdf_oid = DGDF.dgdf_oid
               AND DGDP1.bfdf_oid = BFDF.bfdf_oid
               AND BERL.berl_oid = DGDP2.berl_oid) lookupkey_fld_label_txt,
       (SELECT DISTINCT bus_entity_data_nme
        FROM   ft_o_uisc) gso_uisc
WHERE  lookupkey_rel_nme.rel_nme(+) = gso_rel_gso.rel_name_dsp_txt
       AND lookupkey_fld_label_txt.fld_label_txt(+) = gso_rel_gso.rel_name_dsp_txt
       AND ( lookupkey_rel_nme.datagroup_lookupkey_rel_nme IS NULL AND lookupkey_fld_label_txt.datagroup_lookupkey_fld_label_txt IS NULL )
       AND gso_rel_gso.gso_name = gso_uisc.bus_entity_data_nme
    """