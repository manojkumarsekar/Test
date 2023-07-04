select distinct acid.ACCT_ALT_ID as FUND_CODE,bnid.BNCHMRK_ID as BENCHMARK_CODE from
ft_t_acid acid,
ft_t_abmr abmr,
(select bnch_oid, bnchmrk_id from ft_t_bnid where bnchmrk_id_ctxt_typ = 'BRSBNCHID' and substr(bnchmrk_id,0,3) = 'GMP' and end_tms is null and bnch_oid  in (
select bnch.bnch_oid
from ft_t_bnch bnch
inner join ft_t_bnpt bnpt on bnpt.prnt_bnch_oid=bnch.bnch_oid
inner join ft_t_bnvl bnvl on bnvl.bnpt_oid=bnpt.bnpt_oid
inner join ft_t_bnid bnid on bnch.bnch_oid=bnid.bnch_oid and bnchmrk_id_ctxt_typ = 'BRSBNCHID' and substr(bnchmrk_id,0,3) = 'GMP'
Where
trunc(bnvl.bnchmrk_val_tms) in (
select  max(bnvl.bnchmrk_val_tms)
from ft_t_bnch bnch
inner join ft_t_bnpt bnpt on bnpt.prnt_bnch_oid=bnch.bnch_oid
inner join ft_t_bnvl bnvl on bnvl.bnpt_oid=bnpt.bnpt_oid
inner join ft_t_bnid bnid on bnid.bnch_oid=bnch.bnch_oid and bnchmrk_id_ctxt_typ = 'BRSBNCHID' and substr(bnchmrk_id,0,3) = 'GMP'
where trunc(bnvl.bnchmrk_val_tms)< trunc(sysdate)
))) bnid
where
acid.acct_id_ctxt_typ = 'IRPID' and acid.end_tms is null and acid.acct_id=abmr.acct_id and
abmr.rl_typ = 'PRIMARY' and abmr.end_tms is null and abmr.bnch_oid=bnid.bnch_oid
and rownum=1