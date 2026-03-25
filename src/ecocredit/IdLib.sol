// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { InvalidAbbreviation } from "./Errors.sol";

/// @title IdLib
/// @notice ID formatting and validation library for the ecocredit module.
/// @dev Maps to regen-ledger/x/ecocredit/base/utils.go.
///      All ID generation happens on-chain, matching the Go implementation.
///
///      Go Validate* functions for generated IDs (ValidateClassID, ValidateProjectID,
///      ValidateBatchDenom) are NOT ported. Since we generate these IDs on-chain via
///      the format functions below, the output is correct by construction. Validation
///      of generated output is unnecessary.
library IdLib {
    using Strings for uint256;

    // ── Format Functions ────────────────────────────────────────────────

    /// @notice Format a credit class ID.
    /// @dev Maps to base.FormatClassID: fmt.Sprintf("%s%02d", abbrev, seqNo)
    ///      Format: {abbrev}{seq} where seq is zero-padded to at least 2 digits.
    ///      e.g. "C01", "BIO03", "C100"
    function formatClassId(
        string memory abbrev,
        uint256 seq
    ) internal pure returns (string memory) {
        return string.concat(abbrev, zeroPad(seq, 2));
    }

    /// @notice Format a project ID.
    /// @dev Maps to base.FormatProjectID: fmt.Sprintf("%s-%03d", classID, seqNo)
    ///      Format: {classId}-{seq} where seq is zero-padded to at least 3 digits.
    ///      e.g. "C01-001"
    function formatProjectId(
        string memory classId,
        uint256 seq
    ) internal pure returns (string memory) {
        return string.concat(classId, "-", zeroPad(seq, 3));
    }

    /// @notice Format a batch denomination.
    /// @dev Maps to base.FormatBatchDenom:
    ///      fmt.Sprintf("%s-%s-%s-%03d", projectID, startYYYYMMDD, endYYYYMMDD, seqNo)
    ///      Format: {projectId}-{YYYYMMDD}-{YYYYMMDD}-{seq}
    ///      e.g. "C01-001-20190101-20200101-001"
    function formatBatchDenom(
        string memory projectId,
        uint48 startDate,
        uint48 endDate,
        uint256 seq
    ) internal pure returns (string memory) {
        return string.concat(
            projectId,
            "-",
            timestampToDateString(startDate),
            "-",
            timestampToDateString(endDate),
            "-",
            zeroPad(seq, 3)
        );
    }

    // ── Validation Functions ────────────────────────────────────────────

    /// @notice Validate a credit type abbreviation: 1-3 uppercase ASCII [A-Z].
    /// @dev Maps to base.ValidateCreditTypeAbbreviation with regex ^[A-Z]{1,3}$.
    ///      This is a boundary check called once in addCreditType. The abbreviation
    ///      is stored as string (not bytes3) because it is used in string
    ///      concatenation for ID generation and as a string key throughout the
    ///      protocol, matching the Go implementation. Using bytes3 would also cap
    ///      the number of possible abbreviations at 26^3 = 17,576.
    function validateAbbreviation(string memory abbrev) internal pure {
        bytes memory b = bytes(abbrev);
        if (b.length == 0 || b.length > 3) {
            revert InvalidAbbreviation(abbrev);
        }
        for (uint256 i = 0; i < b.length; i++) {
            // 0x41 = 'A', 0x5A = 'Z'
            if (b[i] < 0x41 || b[i] > 0x5A) {
                revert InvalidAbbreviation(abbrev);
            }
        }
    }

    // ── Internal Helpers ────────────────────────────────────────────────

    /// @notice Convert a unix timestamp to a "YYYYMMDD" date string.
    /// @dev Uses the Howard Hinnant civil date algorithm to convert days since
    ///      epoch to (year, month, day). Matches Go's time.Time.Format("20060102").
    ///      Reference: https://howardhinnant.github.io/date_algorithms.html
    function timestampToDateString(uint48 timestamp) internal pure returns (string memory) {
        (uint256 year, uint256 month, uint256 day) = _daysToDate(uint256(timestamp) / 86400);
        return string.concat(zeroPad(year, 4), zeroPad(month, 2), zeroPad(day, 2));
    }

    /// @notice Left-pad a number with zeros to reach minWidth characters.
    /// @dev If the number already has >= minWidth digits, returns it as-is.
    function zeroPad(uint256 value, uint256 minWidth) internal pure returns (string memory) {
        string memory str = value.toString();
        uint256 len = bytes(str).length;
        if (len >= minWidth) return str;

        bytes memory padded = new bytes(minWidth - len);
        for (uint256 i = 0; i < padded.length; i++) {
            padded[i] = "0";
        }
        return string.concat(string(padded), str);
    }

    /// @notice Convert days since unix epoch to (year, month, day).
    /// @dev Howard Hinnant's civil_from_days algorithm.
    ///      Input: number of days since 1970-01-01
    ///      Output: (year, month [1-12], day [1-31])
    function _daysToDate(
        uint256 epochDays
    ) private pure returns (uint256 year, uint256 month, uint256 day) {
        // Shift epoch from 1970-01-01 to 0000-03-01
        uint256 z = epochDays + 719468;
        // Compute era (400-year period)
        uint256 era = z / 146097;
        // Day within era [0, 146096]
        uint256 doe = z - era * 146097;
        // Year within era [0, 399]
        uint256 yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365;
        // Year
        year = yoe + era * 400;
        // Day of year [0, 365]
        uint256 doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
        // Month [0, 11] (March = 0)
        uint256 mp = (5 * doy + 2) / 153;
        // Day [1, 31]
        day = doy - (153 * mp + 2) / 5 + 1;
        // Adjust month to [1, 12] with January = 1
        month = mp < 10 ? mp + 3 : mp - 9;
        // Adjust year for January and February
        if (month <= 2) year += 1;
    }
}
