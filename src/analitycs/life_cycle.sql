-- curiosa: idade < 7
-- fiel: ideade >= 7 e recencia <7 e recencia anterior < 15
---- turista: recescenia <= 14
-- desencantado: recencia > 14 e recencia <= 28
-- zumbi: recencia > 28
-- reconquistado: recencia < 7 e recencia anterior <=14 e recencia anterior <= 28
-- reborn: recencia < 7 e recencia anterior > 28

WITH tb_daily AS (
    SELECT DISTINCT
        idCliente,
        substr(DtCriacao, 0, 11) as dtDia 
    FROM transacoes
    WHERE DtCriacao <= '{date}'
),

tb_idade AS (
SELECT 
    DISTINCT idCliente,
   -- min(dtDia) as dtPrimeiraTransacao,
   -- max(dtDia) as dtUltimaTransacao,
    CAST(julianday('{date}') - julianday(min(dtDia)) AS INTEGER) as idade,
    CAST(max(julianday('{date}') - julianday(dtDia)) AS INTEGER) as qtdeDiasPrimTransacao,
    CAST(min(julianday('{date}') - julianday(dtDia)) AS INTEGER) as qtdeDiasUltTransacao
FROM tb_daily
GROUP BY idCliente
),

tb_rn AS (
SELECT 
    row_number() over (PARTITION by idCliente order by dtDia desc) as row_id,*
from tb_daily
),

tb_penultima_ativacao AS (
SELECT 
    idCliente,
    CAST((julianday('{date}') - julianday(dtDia)) AS INTEGER) as qtDiasPenultimaTransacao
FROM tb_rn
WHERE row_id = 2
),
tb_lifecycle AS (
select 
    t1.idCliente,
    t1.qtdeDiasPrimTransacao,
    t1.qtdeDiasUltTransacao,
    coalesce(t2.qtDiasPenultimaTransacao,1) as qtDiasPenultimaTransacao,
    CASE
            WHEN qtdeDiasPrimTransacao <= 7 THEN '01-CURIOSO'
            WHEN qtdeDiasUltTransacao <= 7 AND qtDiasPenultimaTransacao - qtdeDiasUltTransacao <= 14 THEN '02-FIEL'
            WHEN qtdeDiasUltTransacao BETWEEN 8 AND 14 THEN '03-TURISTA'
            WHEN qtdeDiasUltTransacao BETWEEN 15 AND 27 THEN '04-DESENCANTADA'
            WHEN qtdeDiasUltTransacao > 27 THEN '05-ZUMBI'
            WHEN qtdeDiasUltTransacao <= 7 AND qtDiasPenultimaTransacao - qtdeDiasUltTransacao BETWEEN 15 AND 27 THEN '02-RECONQUISTADO'
            WHEN qtdeDiasUltTransacao <= 7 AND qtDiasPenultimaTransacao - qtdeDiasUltTransacao > 27 THEN '02-REBORN'
    END as desclifecycle       
from tb_idade as t1
left join tb_penultima_ativacao as t2
on t1.idCliente = t2.idCliente
)
SELECT 
    date('{date}','-1 day') as dtRef,
    * 
FROM tb_lifecycle