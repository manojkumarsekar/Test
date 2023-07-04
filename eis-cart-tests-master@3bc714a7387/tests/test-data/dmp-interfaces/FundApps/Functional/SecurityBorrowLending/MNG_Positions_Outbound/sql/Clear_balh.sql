delete ft_T_bhst where balh_oid in (select balh_oid from (select balh.*,rownum as RN 
from ft_T_balh balh where RQSTR_ID ='BRSEOD' 
and as_of_tms = (select max(as_of_tms) from ft_T_balh where RQSTR_ID ='BRSEOD')) where RN >=2);
delete ft_T_bhst where balh_oid in (select balh_oid from (select balh.*,rownum as RN 
from ft_T_balh balh where RQSTR_ID ='TMBAMEOD'
and as_of_tms = (select max(as_of_tms) from ft_T_balh where RQSTR_ID ='TMBAMEOD')) where RN >=2);
delete ft_T_bhst where balh_oid in (select balh_oid from (select balh.*,rownum as RN 
from ft_T_balh balh where RQSTR_ID ='ESJPEOD' 
and as_of_tms = (select max(as_of_tms) from ft_T_balh where RQSTR_ID ='ESJPEOD')) where RN >=2);
delete ft_T_bhst where balh_oid in (select balh_oid from (select balh.*,rownum as RN 
from ft_T_balh balh where RQSTR_ID ='BNPNPSOD' 
and as_of_tms = (select max(as_of_tms) from ft_T_balh where RQSTR_ID ='BNPNPSOD')) where RN >=2);
delete ft_T_bhst where balh_oid in (select balh_oid from (select balh.*,rownum as RN 
from ft_T_balh balh where RQSTR_ID ='EOD' 
and as_of_tms = (select max(as_of_tms) from ft_T_balh where RQSTR_ID ='EOD')) where RN >=2);
delete ft_T_bhst where balh_oid in (select balh_oid from (select balh.*,rownum as RN 
from ft_T_balh balh where RQSTR_ID ='INTRNL' 
and as_of_tms = (select max(as_of_tms) from ft_T_balh where RQSTR_ID ='INTRNL')) where RN >=2);
delete ft_T_bhst where balh_oid in (select balh_oid from (select balh.*,rownum as RN 
from ft_T_balh balh where RQSTR_ID ='MNGEOD' 
and as_of_tms = (select max(as_of_tms) from ft_T_balh where RQSTR_ID ='MNGEOD')) where RN >=2);
delete ft_T_bhst where balh_oid in (select balh_oid from (select balh.*,rownum as RN 
from ft_T_balh balh where RQSTR_ID ='EISEOD' 
and as_of_tms = (select max(as_of_tms) from ft_T_balh where RQSTR_ID ='EISEOD')) where RN >=2);
delete ft_T_bhst where balh_oid in (select balh_oid from (select balh.*,rownum as RN 
from ft_T_balh balh where RQSTR_ID ='WFOEEOD' 
and as_of_tms = (select max(as_of_tms) from ft_T_balh where RQSTR_ID ='WFOEEOD')) where RN >=2);
delete ft_T_bhst where balh_oid in (select balh_oid from (select balh.*,rownum as RN 
from ft_T_balh balh where RQSTR_ID ='PPMEOD' 
and as_of_tms = (select max(as_of_tms) from ft_T_balh where RQSTR_ID ='PPMEOD')) where RN >=2);
delete ft_T_bhst where balh_oid in (select balh_oid from (select balh.*,rownum as RN 
from ft_T_balh balh where RQSTR_ID ='ESGAEOD' 
and as_of_tms = (select max(as_of_tms) from ft_T_balh where RQSTR_ID ='ESGAEOD')) where RN >=2);
delete ft_T_bhst where balh_oid in (select balh_oid from (select balh.*,rownum as RN 
from ft_T_balh balh where RQSTR_ID ='BRSNPEOD' 
and as_of_tms = (select max(as_of_tms) from ft_T_balh where RQSTR_ID ='BRSNPEOD')) where RN >=2);
delete ft_T_bhst where balh_oid in (select balh_oid from (select balh.*,rownum as RN 
from ft_T_balh balh where RQSTR_ID ='SOD' 
and as_of_tms = (select max(as_of_tms) from ft_T_balh where RQSTR_ID ='SOD')) where RN >=2);
delete ft_T_bhst where balh_oid in (select balh_oid from (select balh.*,rownum as RN 
from ft_T_balh balh where RQSTR_ID ='KOREAEOD' 
and as_of_tms = (select max(as_of_tms) from ft_T_balh where RQSTR_ID ='KOREAEOD')) where RN >=2);
delete ft_T_bhst where balh_oid in (select balh_oid from (select balh.*,rownum as RN 
from ft_T_balh balh where RQSTR_ID ='BOCIEOD' 
and as_of_tms = (select max(as_of_tms) from ft_T_balh where RQSTR_ID ='BOCIEOD')) where RN >=2);

delete ft_T_balh where balh_oid in (select balh_oid from (select balh.*,rownum as RN 
from ft_T_balh balh where RQSTR_ID ='BRSEOD' 
and as_of_tms = (select max(as_of_tms) from ft_T_balh where RQSTR_ID ='BRSEOD')) where RN >=2);

delete ft_T_balh where balh_oid in (select balh_oid from (select balh.*,rownum as RN 
from ft_T_balh balh where RQSTR_ID ='TMBAMEOD'
and as_of_tms = (select max(as_of_tms) from ft_T_balh where RQSTR_ID ='TMBAMEOD')) where RN >=2);
delete ft_T_balh where balh_oid in (select balh_oid from (select balh.*,rownum as RN 
from ft_T_balh balh where RQSTR_ID ='ESJPEOD' 
and as_of_tms = (select max(as_of_tms) from ft_T_balh where RQSTR_ID ='ESJPEOD')) where RN >=2);
delete ft_T_balh where balh_oid in (select balh_oid from (select balh.*,rownum as RN 
from ft_T_balh balh where RQSTR_ID ='BNPNPSOD' 
and as_of_tms = (select max(as_of_tms) from ft_T_balh where RQSTR_ID ='BNPNPSOD')) where RN >=2);
delete ft_T_balh where balh_oid in (select balh_oid from (select balh.*,rownum as RN 
from ft_T_balh balh where RQSTR_ID ='EOD' 
and as_of_tms = (select max(as_of_tms) from ft_T_balh where RQSTR_ID ='EOD')) where RN >=2);
delete ft_T_balh where balh_oid in (select balh_oid from (select balh.*,rownum as RN 
from ft_T_balh balh where RQSTR_ID ='INTRNL' 
and as_of_tms = (select max(as_of_tms) from ft_T_balh where RQSTR_ID ='INTRNL')) where RN >=2);
delete ft_T_balh where balh_oid in (select balh_oid from (select balh.*,rownum as RN 
from ft_T_balh balh where RQSTR_ID ='MNGEOD' 
and as_of_tms = (select max(as_of_tms) from ft_T_balh where RQSTR_ID ='MNGEOD')) where RN >=2);
delete ft_T_balh where balh_oid in (select balh_oid from (select balh.*,rownum as RN 
from ft_T_balh balh where RQSTR_ID ='EISEOD' 
and as_of_tms = (select max(as_of_tms) from ft_T_balh where RQSTR_ID ='EISEOD')) where RN >=2);
delete ft_T_balh where balh_oid in (select balh_oid from (select balh.*,rownum as RN 
from ft_T_balh balh where RQSTR_ID ='WFOEEOD' 
and as_of_tms = (select max(as_of_tms) from ft_T_balh where RQSTR_ID ='WFOEEOD')) where RN >=2);
delete ft_T_balh where balh_oid in (select balh_oid from (select balh.*,rownum as RN 
from ft_T_balh balh where RQSTR_ID ='PPMEOD' 
and as_of_tms = (select max(as_of_tms) from ft_T_balh where RQSTR_ID ='PPMEOD')) where RN >=2);
delete ft_T_balh where balh_oid in (select balh_oid from (select balh.*,rownum as RN 
from ft_T_balh balh where RQSTR_ID ='ESGAEOD' 
and as_of_tms = (select max(as_of_tms) from ft_T_balh where RQSTR_ID ='ESGAEOD')) where RN >=2);
delete ft_T_balh where balh_oid in (select balh_oid from (select balh.*,rownum as RN 
from ft_T_balh balh where RQSTR_ID ='BRSNPEOD' 
and as_of_tms = (select max(as_of_tms) from ft_T_balh where RQSTR_ID ='BRSNPEOD')) where RN >=2);
delete ft_T_balh where balh_oid in (select balh_oid from (select balh.*,rownum as RN 
from ft_T_balh balh where RQSTR_ID ='SOD' 
and as_of_tms = (select max(as_of_tms) from ft_T_balh where RQSTR_ID ='SOD')) where RN >=2);
delete ft_T_balh where balh_oid in (select balh_oid from (select balh.*,rownum as RN 
from ft_T_balh balh where RQSTR_ID ='KOREAEOD' 
and as_of_tms = (select max(as_of_tms) from ft_T_balh where RQSTR_ID ='KOREAEOD')) where RN >=2);
delete ft_T_balh where balh_oid in (select balh_oid from (select balh.*,rownum as RN 
from ft_T_balh balh where RQSTR_ID ='BOCIEOD' 
and as_of_tms = (select max(as_of_tms) from ft_T_balh where RQSTR_ID ='BOCIEOD')) where RN >=2);