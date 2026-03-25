// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/// @title Ecocredit Data Types
/// @notice Shared structs and enums for the ecocredit base module.
/// @dev Maps from regen-ledger protobuf definitions:
///      - state.proto: regen/ecocredit/v1/state.proto
///      - types.proto: regen/ecocredit/v1/types.proto
///
///      Recurring type mapping conventions (proto -> Solidity):
///      - bytes (addresses)              -> address    (Solidity native address type)
///      - string (decimal amounts)       -> uint256    (fixed-point integer, no string math in EVM)
///      - uint64 (keys/IDs)              -> uint256    (Solidity native word size, 256-bit storage slots)
///      - google.protobuf.Timestamp      -> uint48     (OpenZeppelin Time.sol convention)
///      - snake_case field names          -> camelCase  (Solidity naming convention)
///      - `contract` field name           -> contract_  (`contract` is a reserved keyword in Solidity)
///      - PROJECT_ENROLLMENT_STATUS_X     -> X          (Solidity enums are scoped to their type,
///                                                       so the proto prefix is redundant)
///
///      Proto types NOT included here (deferred or expressed as contract storage):
///      - Credits (types.proto)           -> deferred to CreditLedger phase
///      - Params (types.proto)            -> deprecated in Revision 2
///      - CreditTypeProposal (types.proto)-> deprecated legacy governance proposal
///      - AllowedDenom (types.proto)      -> marketplace-specific, deprecated Revision 2
///      - BatchContract (state.proto)     -> deferred to bridge phase
///      - ClassIssuer, ClassSequence, ProjectSequence, BatchSequence, OriginTxIndex,
///        ClassCreatorAllowlist, AllowedClassCreator, ClassFee, AllowedBridgeChain,
///        ProjectFee (state.proto)        -> simple mappings/variables in contract storage,
///                                           no struct needed
///
///      Numeric keys use UDVTs (User Defined Value Types) over uint256 for
///      zero-cost type safety: a ClassKey cannot be passed where a ProjectKey
///      is expected, preventing key confusion bugs at compile time.
///      No major protocol uses this exact pattern for auto-increment row IDs,
///      but UDVTs over uint256/bytes32/address are standard practice
///      (Uniswap v4 PoolId, Currency; OpenZeppelin Delay, ShortString).

/// @notice Type-safe key for credit class table rows.
type ClassKey is uint256;

/// @notice Type-safe key for project table rows.
type ProjectKey is uint256;

/// @notice Type-safe key for credit batch table rows.
type BatchKey is uint256;

/// @notice Project enrollment lifecycle states.
/// @dev Maps to regen.ecocredit.v1.ProjectEnrollmentStatus
enum ProjectEnrollmentStatus {
    UNSPECIFIED, // 0 — submitted, pending review
    ACCEPTED, // 1 — approved
    CHANGES_REQUESTED, // 2 — needs modification
    REJECTED, // 3 — denied (record deleted from state)
    TERMINATED // 4 — revoked (record deleted from state)
}

/// @notice Defines a category of ecological credit (e.g. carbon, biodiversity).
/// @dev Maps to regen.ecocredit.v1.CreditType (state.proto table 1).
struct CreditType {
    // abbreviation is a 1-3 character uppercase abbreviation of the CreditType
    // name, used in batch denominations within the CreditType. It must be unique.
    string abbreviation;
    // name is the name of the credit type (e.g. carbon, biodiversity).
    string name;
    // unit is the measurement unit of the credit type (e.g. kg, ton).
    string unit;
    // precision is the decimal precision of the credit type.
    uint32 precision;
}

/// @notice A credit class groups projects under a credit type with shared issuers.
/// @dev Maps to regen.ecocredit.v1.Class (state.proto table 2).
struct Class {
    // key is the table row identifier of the credit class used internally for
    // efficient lookups. This identifier is auto-incrementing.
    ClassKey key;
    // id is the unique identifier of the credit class auto-generated from the
    // credit type abbreviation and the credit class sequence number.
    string id; // format: {abbrev}{seq:02d}, e.g. "C01"
    // admin is the admin of the credit class.
    address admin;
    // metadata is any arbitrary metadata to attached to the credit class.
    string metadata;
    // credit_type_abbrev is the abbreviation of the credit type.
    string creditTypeAbbrev;
}

/// @notice Project represents the high-level on-chain information for a project.
/// @dev Maps to regen.ecocredit.v1.Project (state.proto table 4).
struct Project {
    // key is the table row identifier of the project used internally for
    // efficient lookups. This identifier is auto-incrementing.
    ProjectKey key;
    // id is the unique identifier of the project either auto-generated from the
    // credit class id and project sequence number or provided upon creation.
    string id; // format: {classId}-{seq:03d}, e.g. "C01-001"
    // admin is the admin of the project.
    address admin;
    // class_key is the table row identifier of the credit class used internally
    // for efficient lookups. This links a project to a credit class.
    ClassKey classKey;
    // jurisdiction is the jurisdiction of the project.
    // Full documentation can be found in MsgCreateProject.jurisdiction.
    string jurisdiction; // ISO 3166-2: {CC}[-{region}[ {postal}]]
    // metadata is any arbitrary metadata attached to the project.
    string metadata;
    // reference_id is any arbitrary string used to reference the project.
    string referenceId; // max 32 chars, unique per class if non-empty
}

/// @notice A credit batch represents credits issued for a monitoring period.
/// @dev Maps to regen.ecocredit.v1.Batch (state.proto table 5).
struct Batch {
    // key is the table row identifier of the credit batch used internally for
    // efficient lookups. This identifier is auto-incrementing.
    BatchKey key;
    // issuer is the address that created the batch and which is
    // authorized to mint more credits if open=true.
    address issuer; // immutable after creation
    // project_key is the table row identifier of the project used internally
    // for efficient lookups. This links a credit batch to a project.
    ProjectKey projectKey;
    // denom is the unique identifier of the credit batch formed from the
    // project id, the batch sequence number, and the start and
    // end date of the credit batch.
    string denom; // format: {projId}-{YYYYMMDD}-{YYYYMMDD}-{seq:03d}
    // metadata is any arbitrary metadata attached to the credit batch.
    string metadata;
    // start_date is the beginning of the period during which this credit batch
    // was quantified and verified.
    uint48 startDate;
    // end_date is the end of the period during which this credit batch was
    // quantified and verified.
    uint48 endDate;
    // issuance_date is the timestamp when the credit batch was issued.
    uint48 issuanceDate; // block.timestamp at creation
    // open tells if it's possible to mint new credits in the future.
    // Once `open` is set to false, it can't be toggled any more.
    bool open;
    // class_key is the table row identifier of the credit class used internally
    // for efficient lookups. This links a batch to a credit class.
    ClassKey classKey;
}

/// @notice Per-account balance for a specific credit batch.
/// @dev Maps to regen.ecocredit.v1.BatchBalance (state.proto table 9).
///      All amounts are uint256 scaled by 10^creditType.precision.
///      Keys are included because regen-ledger uses them in invariant checks,
///      supply aggregation, and query response building (not just as ORM indexes).
struct BatchBalance {
    // batch_key is the table row identifier of the credit batch used internally
    // for efficient lookups. This links a balance to a credit batch.
    BatchKey batchKey;
    // Proto field is `bytes address`. Renamed to `holder` because `address`
    // is a reserved keyword in Solidity (it is a type name).
    address holder;
    // tradable_amount is the total number of tradable credits owned by holder.
    uint256 tradableAmount;
    // retired_amount is the total number of retired credits owned by holder.
    uint256 retiredAmount;
    // escrowed_amount is the total number of escrowed credits owned by holder
    // and held in escrow by the marketplace. Credits are held in escrow when a
    // sell order is created and taken out of escrow when the sell order is either
    // cancelled, updated with a reduced quantity, or processed.
    uint256 escrowedAmount;
}

/// @notice Aggregate supply tracking for a credit batch.
/// @dev Maps to regen.ecocredit.v1.BatchSupply (state.proto table 10).
///      Invariant: tradable + retired + cancelled == total ever minted.
///      batchKey is included because regen-ledger uses it in invariant checks
///      and supply aggregation (not just as an ORM index).
struct BatchSupply {
    // batch_key is the table row identifier of the credit batch used internally
    // for efficient lookups. This links supply to a credit batch.
    BatchKey batchKey;
    // tradable_amount is the total number of tradable credits in the batch.
    uint256 tradableAmount;
    // retired_amount is the total number of retired credits in the batch.
    uint256 retiredAmount;
    // cancelled_amount is the total number of cancelled credits in the batch.
    uint256 cancelledAmount;
}

/// @notice Tracks a project's enrollment lifecycle within a credit class.
/// @dev Maps to regen.ecocredit.v1.ProjectEnrollment (state.proto table 17).
///      Proto fields project_key and class_key are omitted following Solidity
///      convention (OZ Governor, AccessControl, Uniswap v4): they serve only as
///      ORM primary keys in regen-ledger with no downstream business logic usage.
///      In Solidity they are the mapping keys: mapping(uint256 => mapping(uint256 => ProjectEnrollment)).
struct ProjectEnrollment {
    // status is the status of the project enrollment.
    ProjectEnrollmentStatus status;
    // application_metadata is any arbitrary string with a maximum length of 256
    // characters used to store metadata submitted by the project admin.
    string applicationMetadata;
    // enrollment_metadata is any arbitrary string with a maximum length of 256
    // characters used to store metadata submitted by the class issuer.
    string enrollmentMetadata;
}

/// @notice Specifies how credits should be issued within a batch.
/// @dev Maps to regen.ecocredit.v1.BatchIssuance (types.proto).
struct BatchIssuance {
    // recipient is the address of the account receiving the issued credits.
    address recipient;
    // tradable_amount is the number of credits to issue as tradable.
    uint256 tradableAmount;
    // retired_amount is the number of credits to issue as retired.
    uint256 retiredAmount;
    // retirement_jurisdiction is the jurisdiction of the beneficiary or buyer
    // of the retired credits. Required if retired_amount is positive.
    string retirementJurisdiction;
    // retirement_reason is any arbitrary string that specifies the reason for
    // retiring credits.
    string retirementReason;
}

/// @notice Reference to an external origin transaction (for bridging).
/// @dev Maps to regen.ecocredit.v1.OriginTx (types.proto).
struct OriginTx {
    // id is the transaction ID of an originating transaction or operation.
    string id;
    // source is the source chain or registry of the transaction originating
    // the mint process (e.g. "polygon", "verra").
    string source;
    // contract is the address of the contract on the source chain that
    // originated the mint process.
    string contract_;
    // note is a reference note for accounting purposes.
    string note;
}
