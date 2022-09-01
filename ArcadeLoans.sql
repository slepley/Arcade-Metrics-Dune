/*
Platform Metrics for NFT Lending Protocol Arcade.xyz

execute query here: https://dune.com/queries/1130687/1941626
*/
select * from 
    (select x."call_block_time",x."loanId",x."lender",x."borrower",x."durationdays",x."principal",x."apr",x."loan_currency",
        (CASE WHEN x."loan_currency" = 'ETH' THEN x."principal" * x."eth_price" ELSE x."principal"END) as loan_value_usd,
        x."eth_price" as daily_eth_price,
        x."contract_address",x."call_tx_hash"
    from
      (
        select * from(
        /* V1 contract */
            (SELECT sv1."call_block_time",sv1."loanId",sv1."lender",sv1."borrower",(created_qv."durationsecs"/86400) as durationdays,
                CASE WHEN created_qv."currency"::text = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'::text THEN(created_qv."principal"/1e18) WHEN created_qv."currency"::text = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48'::text THEN (created_qv."principal"/1e6) END as principal,
                (((created_qv."interest"/created_qv."principal")/(created_qv."durationsecs"/86400) * 365)*100) as APR,CASE WHEN created_qv."currency"::text = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'::text THEN 'ETH' WHEN created_qv."currency"::text = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48'::text THEN 'USDC' WHEN created_qv."currency"::text = '0x6b175474e89094c44da98b954eedeac495271d0f'::text THEN 'DAI' ELSE created_qv."currency"::text END AS loan_currency,
                sv1."contract_address",sv1."call_tx_hash",date_trunc('day', sv1."call_block_time") as day
                from pawnfi."LoanCore_call_startLoan" sv1 
            LEFT JOIN 
                (select CAST(cv.terms->>'durationSecs' as numeric(999,1)) as durationSecs,CAST(cv.terms->>'interest' as numeric(999,1)) as interest, CAST(cv.terms->>'principal' as numeric(999,1)) as principal, 
                    cv.terms->>'payableCurrency' as currency,cv."loanId",cv."evt_tx_hash",cv."evt_block_time",cv."evt_block_number" from pawnfi."LoanCore_evt_LoanCreated" cv) as created_qv
                        on sv1."call_tx_hash" = created_qv."evt_tx_hash")
                        
            /*V2 CONTRACT*/
            UNION 
                (SELECT sv2."call_block_time",sv2."loanId",sv2."lender",sv2."borrower",(created_qv2."durationsecs"/86400) as durationdays,
                CASE WHEN created_qv2."currency"::text = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'::text THEN(created_qv2."principal"/1e18) WHEN created_qv2."currency"::text = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48'::text THEN (created_qv2."principal"/1e6) END as principal,
                (((created_qv2."interest"/created_qv2."principal")/(created_qv2."durationsecs"/86400) * 365)*100) as APR,CASE WHEN created_qv2."currency"::text = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'::text THEN 'ETH' WHEN created_qv2."currency"::text = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48'::text THEN 'USDC' WHEN created_qv2."currency"::text = '0x6b175474e89094c44da98b954eedeac495271d0f'::text THEN 'DAI' ELSE created_qv2."currency"::text END AS loan_currency,
                sv2."contract_address",sv2."call_tx_hash",date_trunc('day', sv2."call_block_time") as day
                from pawnfi_v2."LoanCore_call_startLoan" sv2 
            LEFT JOIN 
                (select CAST(cv2.terms->>'durationSecs' as numeric(999,1)) as durationSecs,CAST(cv2.terms->>'interest' as numeric(999,1)) as interest, CAST(cv2.terms->>'principal' as numeric(999,1)) as principal, 
                    cv2.terms->>'payableCurrency' as currency,cv2."loanId",cv2."evt_tx_hash",cv2."evt_block_time",cv2."evt_block_number" from pawnfi_v2."LoanCore_evt_LoanCreated" cv2) as created_qv2
                        on sv2."call_tx_hash" = created_qv2."evt_tx_hash")
                
                        
            /*V2.01 CONTRACT*/
            UNION
                (select sv201."call_block_time",sv201."output_loanId" as loanId,sv201."lender",sv201."borrower", (CAST(sv201.terms->>'durationSecs' as numeric(999,1))/86400) as durationdays, 
                    CASE WHEN sv201.terms->>'payableCurrency'::text = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'::text THEN((CAST(sv201.terms->>'principal' as numeric(999,1)))/1e18) WHEN sv201.terms->>'payableCurrency'::text = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48'::text THEN ((CAST(sv201.terms->>'principal' as numeric(999,1)))/1e6) END as principal,
                    CASE WHEN sv201.terms->>'payableCurrency'::text = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'::text THEN((CAST(sv201.terms->>'interestRate' as numeric(999,1)))/1e20) WHEN sv201.terms->>'payableCurrency'::text = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48'::text THEN ((CAST(sv201.terms->>'interestRate' as numeric(999,1)))/1e20) END as apr,
                    CASE WHEN sv201.terms->>'payableCurrency'::text = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'::text THEN 'ETH' WHEN sv201.terms->>'payableCurrency'::text = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48'::text THEN 'USDC' WHEN sv201.terms->>'payableCurrency'::text = '0x6b175474e89094c44da98b954eedeac495271d0f'::text THEN 'DAI' ELSE sv201.terms->>'payableCurrency'::text END AS loan_currency,
                    sv201."contract_address",sv201."call_tx_hash",date_trunc('day', sv201."call_block_time") as day
                from pawnfi_v201."LoanCore_call_startLoan" sv201)) as combo_table
    LEFT JOIN
        (SELECT date_trunc('day', minute) as day,
                AVG(price) as eth_price
        FROM prices."layer1_usd"
        WHERE "symbol" = 'ETH' AND  date_trunc('day', minute) > date_trunc('day', now()) - interval '1 year'
        GROUP BY 1
        ORDER BY day DESC) as t2
    on combo_table."day" = t2."day"
    ) x
    order by x."call_block_time" desc) loan_table
