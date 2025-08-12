// This is a generated Motoko binding.
// Please use `import service "ic:canister_id"` instead to call canisters on the IC if possible.

module {
  public type Account = { owner : Principal; subaccount : ?Subaccount };
  public type Account__1 = { owner : Principal; subaccount : ?Subaccount__1 };
  public type Account__2 = { owner : Principal; subaccount : ?Blob };
  public type Account__3 = { owner : Principal; subaccount : ?Subaccount__2 };
  public type Account__4 = { owner : Principal; subaccount : ?Subaccount };
  public type AdvancedSettings = {
    existing_balances : [(Account, Balance)];
    burned_tokens : Balance;
    fee_collector_emitted : Bool;
    minted_tokens : Balance;
    local_transactions : [Transaction];
    fee_collector_block : Nat;
  };
  public type AdvancedSettings__1 = {
    existing_approvals : [((Account__1, Account__1), ApprovalInfo)];
  };
  public type Allowance = { allowance : Nat; expires_at : ?Nat64 };
  public type AllowanceArgs = { account : Account__1; spender : Account__1 };
  public type ApprovalInfo = {
    from_subaccount : ?Blob;
    amount : Nat;
    expires_at : ?Nat64;
    spender : Account__1;
  };
  public type ApproveArgs = {
    fee : ?Nat;
    memo : ?Blob;
    from_subaccount : ?Blob;
    created_at_time : ?Nat64;
    amount : Nat;
    expected_allowance : ?Nat;
    expires_at : ?Nat64;
    spender : Account__1;
  };
  public type ApproveError = {
    #GenericError : { message : Text; error_code : Nat };
    #TemporarilyUnavailable;
    #Duplicate : { duplicate_of : Nat };
    #BadFee : { expected_fee : Nat };
    #AllowanceChanged : { current_allowance : Nat };
    #CreatedInFuture : { ledger_time : Nat64 };
    #TooOld;
    #Expired : { ledger_time : Nat64 };
    #InsufficientFunds : { balance : Nat };
  };
  public type ApproveResponse = { #Ok : Nat; #Err : ApproveError };
  public type ArchivedTransactionResponse = {
    args : [TransactionRange];
    callback : GetTransactionsFn;
  };
  public type Balance = Nat;
  public type BalanceQueryArgs = { accounts : [Account__3] };
  public type BalanceQueryResult = [Nat];
  public type Balance__1 = Nat;
  public type BlockType = { url : Text; block_type : Text };
  public type BlockType__1 = { url : Text; block_type : Text };
  public type Burn = {
    from : Account;
    memo : ?Memo;
    created_at_time : ?Timestamp;
    amount : Balance;
  };
  public type BurnArgs = {
    memo : ?Memo;
    from_subaccount : ?Subaccount;
    created_at_time : ?Timestamp;
    amount : Balance;
  };
  public type DataCertificate = { certificate : Blob; hash_tree : Blob };
  public type Fee = { #Environment; #Fixed : Nat };
  public type Fee__1 = { #ICRC1; #Environment; #Fixed : Nat };
  public type Fee__2 = { #ICRC1; #Environment; #Fixed : Nat };
  public type GetArchivesArgs = { from : ?Principal };
  public type GetArchivesResult = [GetArchivesResultItem];
  public type GetArchivesResultItem = {
    end : Nat;
    canister_id : Principal;
    start : Nat;
  };
  public type GetBlocksArgs = [TransactionRange];
  public type GetBlocksResult = {
    log_length : Nat;
    blocks : [{ id : Nat; block : Value__1 }];
    archived_blocks : [ArchivedTransactionResponse];
  };
  public type GetTransactionsFn = shared query [
    TransactionRange
  ] -> async GetTransactionsResult;
  public type GetTransactionsResult = {
    log_length : Nat;
    blocks : [{ id : Nat; block : Value__1 }];
    archived_blocks : [ArchivedTransactionResponse];
  };
  public type IndexType = { #Stable; #StableTyped; #Managed };
  public type InitArgs = {
    fee : ?Fee;
    advanced_settings : ?AdvancedSettings;
    max_memo : ?Nat;
    decimals : Nat8;
    metadata : ?Value;
    minting_account : ?Account;
    logo : ?Text;
    permitted_drift : ?Timestamp;
    name : ?Text;
    settle_to_accounts : ?Nat;
    fee_collector : ?Account;
    transaction_window : ?Timestamp;
    min_burn_amount : ?Balance;
    max_supply : ?Balance;
    max_accounts : ?Nat;
    symbol : ?Text;
  };
  public type InitArgs__1 = {
    fee : ?Fee__1;
    advanced_settings : ?AdvancedSettings__1;
    max_allowance : ?MaxAllowance;
    max_approvals : ?Nat;
    max_approvals_per_account : ?Nat;
    settle_to_approvals : ?Nat;
  };
  public type InitArgs__2 = ?InitArgs__3;
  public type InitArgs__3 = {
    maxRecordsToArchive : Nat;
    archiveIndexType : IndexType;
    maxArchivePages : Nat;
    settleToRecords : Nat;
    archiveCycles : Nat;
    maxActiveRecords : Nat;
    maxRecordsInArchiveInstance : Nat;
    archiveControllers : ??[Principal];
    supportedBlocks : [BlockType];
  };
  public type InitArgs__4 = {
    fee : ?Fee__2;
    max_balances : ?Nat;
    max_transfers : ?Nat;
  };
  public type MaxAllowance = { #TotalSupply; #Fixed : Nat };
  public type Memo = Blob;
  public type MetaDatum = (Text, Value);
  public type Mint = {
    to : Account;
    memo : ?Memo;
    created_at_time : ?Timestamp;
    amount : Balance;
  };
  public type MintFromICPArgs = {
    source_subaccount : ?Blob;
    target : ?Account__2;
    amount : Nat;
  };
  public type Mint__1 = {
    to : Account;
    memo : ?Memo;
    created_at_time : ?Timestamp;
    amount : Balance;
  };
  public type Subaccount = Blob;
  public type Subaccount__1 = Blob;
  public type Subaccount__2 = Blob;
  public type SupportedStandard = { url : Text; name : Text };
  public type Timestamp = Nat64;
  public type Tip = {
    last_block_index : Blob;
    hash_tree : Blob;
    last_block_hash : Blob;
  };
  public type Transaction = {
    burn : ?Burn;
    kind : Text;
    mint : ?Mint;
    timestamp : Timestamp;
    index : TxIndex;
    transfer : ?Transfer;
  };
  public type TransactionRange = { start : Nat; length : Nat };
  public type Transfer = {
    to : Account;
    fee : ?Balance;
    from : Account;
    memo : ?Memo;
    created_at_time : ?Timestamp;
    amount : Balance;
  };
  public type TransferArgs = {
    to : Account;
    fee : ?Balance;
    memo : ?Memo;
    from_subaccount : ?Subaccount;
    created_at_time : ?Timestamp;
    amount : Balance;
  };
  public type TransferArgs__1 = {
    to : Account;
    fee : ?Balance;
    memo : ?Memo;
    from_subaccount : ?Subaccount;
    created_at_time : ?Timestamp;
    amount : Balance;
  };
  public type TransferBatchArgs = [TransferArgs];
  public type TransferBatchError = {
    #TooManyRequests : { limit : Nat };
    #GenericError : { message : Text; error_code : Nat };
    #TemporarilyUnavailable;
    #BadBurn : { min_burn_amount : Nat };
    #Duplicate : { duplicate_of : Nat };
    #BadFee : { expected_fee : Nat };
    #CreatedInFuture : { ledger_time : Nat64 };
    #GenericBatchError : { message : Text; error_code : Nat };
    #TooOld;
    #InsufficientFunds : { balance : Nat };
  };
  public type TransferBatchResult = { #Ok : Nat; #Err : TransferBatchError };
  public type TransferBatchResults = [?TransferBatchResult];
  public type TransferError = {
    #GenericError : { message : Text; error_code : Nat };
    #TemporarilyUnavailable;
    #BadBurn : { min_burn_amount : Balance };
    #Duplicate : { duplicate_of : TxIndex };
    #BadFee : { expected_fee : Balance };
    #CreatedInFuture : { ledger_time : Timestamp };
    #TooOld;
    #InsufficientFunds : { balance : Balance };
  };
  public type TransferFromArgs = {
    to : Account__1;
    fee : ?Nat;
    spender_subaccount : ?Blob;
    from : Account__1;
    memo : ?Blob;
    created_at_time : ?Nat64;
    amount : Nat;
  };
  public type TransferFromError = {
    #GenericError : { message : Text; error_code : Nat };
    #TemporarilyUnavailable;
    #InsufficientAllowance : { allowance : Nat };
    #BadBurn : { min_burn_amount : Nat };
    #Duplicate : { duplicate_of : Nat };
    #BadFee : { expected_fee : Nat };
    #CreatedInFuture : { ledger_time : Nat64 };
    #TooOld;
    #InsufficientFunds : { balance : Nat };
  };
  public type TransferFromResponse = { #Ok : Nat; #Err : TransferFromError };
  public type TransferResult = { #Ok : TxIndex; #Err : TransferError };
  public type TxIndex = Nat;
  public type UpdateLedgerInfoRequest = {
    #Fee : Fee__2;
    #MaxBalances : Nat;
    #MaxTransfers : Nat;
  };
  public type UpdateLedgerInfoRequest__1 = {
    #Fee : Fee__1;
    #MaxAllowance : ?MaxAllowance;
    #MaxApprovalsPerAccount : Nat;
    #MaxApprovals : Nat;
    #SettleToApprovals : Nat;
  };
  public type UpdateLedgerInfoRequest__2 = {
    #Fee : Fee;
    #Metadata : (Text, ?Value);
    #Symbol : Text;
    #Logo : Text;
    #Name : Text;
    #MaxSupply : ?Nat;
    #MaxMemo : Nat;
    #MinBurnAmount : ?Nat;
    #TransactionWindow : Nat64;
    #PermittedDrift : Nat64;
    #SettleToAccounts : Nat;
    #MintingAccount : Account;
    #FeeCollector : ?Account;
    #MaxAccounts : Nat;
    #Decimals : Nat8;
  };
  public type Value = {
    #Int : Int;
    #Map : [(Text, Value)];
    #Nat : Nat;
    #Blob : Blob;
    #Text : Text;
    #Array : [Value];
  };
  public type Value__1 = {
    #Int : Int;
    #Map : [(Text, Value__1)];
    #Nat : Nat;
    #Blob : Blob;
    #Text : Text;
    #Array : [Value__1];
  };
  public type Self = actor {
    admin_init : shared () -> async ();
    admin_update_icrc1 : shared [UpdateLedgerInfoRequest__2] -> async [Bool];
    admin_update_icrc2 : shared [UpdateLedgerInfoRequest__1] -> async [Bool];
    admin_update_icrc4 : shared [UpdateLedgerInfoRequest] -> async [Bool];
    admin_update_owner : shared Principal -> async Bool;
    burn : shared BurnArgs -> async TransferResult;
    deposit_cycles : shared () -> async ();
    get_bonus : shared query () -> async Nat;
    get_minted_count : shared query () -> async Nat;
    get_minted_goal : shared query () -> async Nat;
    get_tip : shared query () -> async Tip;
    icrc10_supported_standards : shared query () -> async [SupportedStandard];
    icrc1_balance_of : shared query Account__4 -> async Balance__1;
    icrc1_decimals : shared query () -> async Nat8;
    icrc1_fee : shared query () -> async Balance__1;
    icrc1_metadata : shared query () -> async [MetaDatum];
    icrc1_minting_account : shared query () -> async ?Account__4;
    icrc1_name : shared query () -> async Text;
    icrc1_supported_standards : shared query () -> async [SupportedStandard];
    icrc1_symbol : shared query () -> async Text;
    icrc1_total_supply : shared query () -> async Balance__1;
    icrc1_transfer : shared TransferArgs__1 -> async TransferResult;
    icrc2_allowance : shared query AllowanceArgs -> async Allowance;
    icrc2_approve : shared ApproveArgs -> async ApproveResponse;
    icrc2_transfer_from : shared TransferFromArgs -> async TransferFromResponse;
    icrc3_get_archives : shared query GetArchivesArgs -> async GetArchivesResult;
    icrc3_get_blocks : shared query GetBlocksArgs -> async GetBlocksResult;
    icrc3_get_tip_certificate : shared query () -> async ?DataCertificate;
    icrc3_supported_block_types : shared query () -> async [BlockType__1];
    icrc4_balance_of_batch : shared query BalanceQueryArgs -> async BalanceQueryResult;
    icrc4_maximum_query_batch_size : shared query () -> async ?Nat;
    icrc4_maximum_update_batch_size : shared query () -> async ?Nat;
    icrc4_transfer_batch : shared TransferBatchArgs -> async TransferBatchResults;
    mint : shared Mint__1 -> async TransferResult;
    mintFromICP : shared MintFromICPArgs -> async TransferResult;
    withdrawICP : shared Nat64 -> async Nat64;
  };
};
