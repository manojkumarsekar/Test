delete ft_T_bhst where balh_oid in
(select balh_oid from (
select balh.balh_oid,balh.RQSTR_ID,balh.as_of_tms,row_number() over (partition by balh.RQSTR_ID order by balh.RQSTR_ID) RN
from ft_T_balh balh inner join
(select distinct as_of_tms,RQSTR_ID from (
select max(as_of_tms) over (partition by RQSTR_ID order by RQSTR_ID) as_of_tms,RQSTR_ID from ft_T_balh
where RQSTR_ID IN ('MNGEOD','BOCIEOD','ESJPEOD','KOREAEOD','TMBAMEOD','EISEOD','PPMEOD','WFOEEOD','EISEOD','ESGAEOD','BRSEOD','ROBOCOLL'))) aj on
balh.as_of_tms=aj.as_of_tms and balh.RQSTR_ID =aj.RQSTR_ID
where
balh.RQSTR_ID  IN ('MNGEOD','BOCIEOD','ESJPEOD','KOREAEOD','TMBAMEOD','EISEOD','PPMEOD','WFOEEOD','EISEOD','ESGAEOD','BRSEOD','ROBOCOLL'))
where RN >=2);
delete ft_T_balh where balh_oid in
(select balh_oid from (
select balh.balh_oid,balh.RQSTR_ID,balh.as_of_tms,row_number() over (partition by balh.RQSTR_ID order by balh.RQSTR_ID) RN
from ft_T_balh balh inner join
(select distinct as_of_tms,RQSTR_ID from (
select max(as_of_tms) over (partition by RQSTR_ID order by RQSTR_ID) as_of_tms,RQSTR_ID from ft_T_balh
where RQSTR_ID IN ('MNGEOD','BOCIEOD','ESJPEOD','KOREAEOD','TMBAMEOD','EISEOD','PPMEOD','WFOEEOD','EISEOD','ESGAEOD','BRSEOD','ROBOCOLL'))) aj on
balh.as_of_tms=aj.as_of_tms and balh.RQSTR_ID =aj.RQSTR_ID
where
balh.RQSTR_ID  IN ('MNGEOD','BOCIEOD','ESJPEOD','KOREAEOD','TMBAMEOD','EISEOD','PPMEOD','WFOEEOD','EISEOD','ESGAEOD','BRSEOD','ROBOCOLL'))
where RN >=2);