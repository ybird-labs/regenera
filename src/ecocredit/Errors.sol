// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {
    ProjectEnrollmentStatus,
    ClassKey,
    ProjectKey,
    BatchKey
} from "./DataTypes.sol";

// Ecocredit Errors
//
// Custom errors for the ecocredit base module.
// These are Solidity-specific. The Go implementation uses sdkerrors.ErrInvalidRequest.Wrapf(...)
// style error wrapping. These typed errors map to the same validation conditions
// found in regen-ledger/x/ecocredit/base/keeper/msg_*.go.

// ── General ─────────────────────────────────────────────────────────────────

error Unauthorized(address caller);
error InvalidAddress(address addr);
error MetadataTooLong(uint256 length, uint256 maxLength);

// ── CreditType ──────────────────────────────────────────────────────────────

error InvalidAbbreviation(string abbreviation);
error CreditTypeAlreadyExists(string abbreviation);
error CreditTypeNotFound(string abbreviation);

// ── Class ───────────────────────────────────────────────────────────────────

error ClassNotFound(string classId);
error ClassNotFoundByKey(ClassKey classKey);
error EmptyIssuers();
error DuplicateIssuer(address issuer);
error NotClassAdmin(address caller, ClassKey classKey);
error NotClassIssuer(address caller, ClassKey classKey);
error ClassCreatorNotAllowed(address creator);
error InsufficientClassFee(uint256 sent, uint256 required);

// ── Project ─────────────────────────────────────────────────────────────────

error ProjectNotFound(string projectId);
error ProjectNotFoundByKey(ProjectKey projectKey);
error NotProjectAdmin(address caller, ProjectKey projectKey);
error DuplicateReferenceId(ClassKey classKey, string referenceId);
error ReferenceIdTooLong(uint256 length, uint256 maxLength);
error InvalidJurisdiction(string jurisdiction);
error InsufficientProjectFee(uint256 sent, uint256 required);

// ── Enrollment ──────────────────────────────────────────────────────────────

error EnrollmentNotFound(ProjectKey projectKey, ClassKey classKey);
error InvalidEnrollmentTransition(ProjectEnrollmentStatus from_, ProjectEnrollmentStatus to_);

// ── Batch ───────────────────────────────────────────────────────────────────

error BatchNotFound(string batchDenom);
error BatchNotFoundByKey(BatchKey batchKey);
error NotBatchIssuer(address caller, BatchKey batchKey);
error BatchNotOpen(BatchKey batchKey);
error InvalidDateRange(uint48 startDate, uint48 endDate);
error OriginTxAlreadyExists(ClassKey classKey, string txId, string source);
error BatchContractAlreadyExists(ClassKey classKey, string contract_);

// ── Balance ─────────────────────────────────────────────────────────────────

error InsufficientTradableBalance(
    BatchKey batchKey, address account, uint256 available, uint256 requested
);

// ── Governance ──────────────────────────────────────────────────────────────

error ClassCreatorAlreadyAllowed(address creator);
error ClassCreatorNotInAllowlist(address creator);
error BridgeChainAlreadyAllowed(string chainName);
error BridgeChainNotAllowed(string chainName);
