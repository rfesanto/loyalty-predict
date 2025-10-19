WITH tb_freq_valor AS(

SELECT 
    idCliente,
    count(DISTINCT substr(DtCriacao,0,11))  as qtdeFrequencia,
    sum(CASE 
            WHEN QtdePontos < 0 THEN 0 
            ELSE QtdePontos
        END)                                as qtdePontosPos,
    sum(abs(QtdePontos))                    as qtdePontosAbs
FROM transacoes
where 
   
    DtCriacao <     '2025-09-01'
 AND   -- base ativa nos ultimos 28 dias
    DtCriacao >=    date('2025-09-01', '-28 day')
GROUP BY idCliente
ORDER BY qtdeFrequencia DESC
),

tb_cluster AS(
SELECT * , 
    CASE
        WHEN qtdeFrequencia <= 10   AND qtdePontosPos >= 1500  THEN '12-HYPER'
        WHEN qtdeFrequencia > 10    AND qtdePontosPos >= 1500  THEN '22-EFICIENTE'
        WHEN qtdeFrequencia <= 10   AND qtdePontosPos >= 750   THEN '11-INDECISO'
        WHEN qtdeFrequencia > 10    AND qtdePontosPos >= 750   THEN '21-ESFORÇADO'
        WHEN qtdeFrequencia < 5     THEN '00-LUKERS'
        WHEN qtdeFrequencia <= 10   THEN '01-PREGUIÇOSOS'
        WHEN qtdeFrequencia > 10    THEN '20-POTENCIAL'
    END AS cluster
FROM tb_freq_valor
)

select * from tb_cluster
