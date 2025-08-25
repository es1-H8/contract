// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

/**
 * @dev Interface for the optional metadata functions from the ERC-20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

/**
 * @dev Interface for DIA Oracle V2
 */
interface IDIAOracleV2 {
    function getValue(string memory key) external view returns (uint128 price, uint128 timestamp);
}

/**
 * @title DIAMultiFeedConverter
 * @dev Converts price feeds from DIA Oracle for a given numerator/denominator pair
 */
contract DIAMultiFeedConverter is IDIAOracleV2 {
    uint256 public staleAfterLastRefresh = 60 minutes;

    address immutable MAIN_DIA_FEED;
    string NUMERATOR_SYMBOL;
    string DENOMENATOR_SYMBOL;

    constructor(address _mainDiaFeed, string memory _numeratorSymbol, string memory _denomenatorSymbol) {
        MAIN_DIA_FEED = _mainDiaFeed;
        NUMERATOR_SYMBOL = _numeratorSymbol;
        DENOMENATOR_SYMBOL = _denomenatorSymbol;
    }

    function getValue(string memory) external view virtual override returns (uint128 price8, uint128 _refreshedLast) {
        (uint128 _numPrice8, uint128 _refreshedLastNum) =
            IDIAOracleV2(MAIN_DIA_FEED).getValue(string.concat(NUMERATOR_SYMBOL, "/USD"));
        (uint128 _denPrice8, uint128 _refreshedLastDen) =
            IDIAOracleV2(MAIN_DIA_FEED).getValue(string.concat(DENOMENATOR_SYMBOL, "/USD"));

        price8 = (10 ** 8 * _denPrice8) / _numPrice8;
        // return the oldest refresh time for staleness
        _refreshedLast = _refreshedLastNum < _refreshedLastDen ? _refreshedLastNum : _refreshedLastDen;
    }
}