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
        WHEN qtdeFrequencia <= 10   AND qtdePontosPos >= 1500   THEN 'HYPERS'
        WHEN qtdeFrequencia > 10    AND qtdePontosPos >= 1500   THEN 'EFICIENTES'
        WHEN qtdeFrequencia <= 10   AND qtdePontosPos >= 750   THEN 'INDECISO'
        WHEN qtdeFrequencia > 10    AND qtdePontosPos >= 750   THEN 'ESFORÇADOS'
        WHEN qtdeFrequencia < 5     THEN 'LUKERS'
        WHEN qtdeFrequencia <= 10   THEN 'PREGUIÇOSOS'
        WHEN qtdeFrequencia > 10    THEN 'POTENCIAL'
    END AS cluster
FROM tb_freq_valor
)

select * from tb_cluster
