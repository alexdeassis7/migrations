INSERT INTO LP_Configuration.LPInternalError(Code, Name, Description, Active)
VALUES
('718', 'ERROR REJECTED BY AML', 'ERROR REJECTED BY AML', 1),
('300', 'Successfully executed', 'Successfully executed', 1),
('100', 'The payout was received and will be processed', 'The payout was received and will be processed', 1),
('200', 'The payout is being processed. You cannot cancel any more', 'The payout is being processed. You cannot cancel any more', 1),
('400', 'The payout was cancelled by the merchant', 'The payout was cancelled by the merchant', 1)

--select * from LP_Configuration.LPInternalError