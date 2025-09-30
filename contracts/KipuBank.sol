// SPDX-License-Identifier: MIT
pragma solidity 0.8.26; 

/**
 * @title KipuBank
 * @author javierpmateos
 * @notice Deposit and withdraw ETH in personal vaults with configurable withdrawal limits and global capacity
 * @dev Implements checks-effects-interactions pattern, custom errors for gas optimization, and safe ETH transfers
 * @custom:educational This contract is for educational purposes only and should not be used in production
 * @custom:security-contact sec***@gmail.com
 * @custom:idioma Lo pongo en inglés porque es buena práctica, ya tuve problemas con la ñ :)
 */

contract KipuBank {
    /*///////////////////////////////////
          Type declarations
    ///////////////////////////////////*/

    /*///////////////////////////////////
           State variables
    ///////////////////////////////////*/
    
    /// @notice Maximum amount that can be withdrawn per transaction (in wei)
    /// @dev This value is set during deployment and cannot be changed
    uint256 public immutable i_withdrawalLimit;
    
    /// @notice Maximum total amount that can be deposited in the bank (in wei)
    /// @dev This value is set during deployment and cannot be changed
    uint256 public immutable i_bankCap;
    
    /// @notice Total amount currently deposited in the bank
    /// @dev This value increases with deposits and decreases with withdrawals
    uint256 public s_totalDeposits;
    
    /// @notice Total number of deposit transactions made
    /// @dev Incremented on each successful deposit
    uint256 public s_depositCount;
    
    /// @notice Total number of withdrawal transactions made
    /// @dev Incremented on each successful withdrawal
    uint256 public s_withdrawalCount;
    
    /// @notice Mapping to track each user's vault balance
    /// @dev Maps user address to their deposited amount in wei
    mapping(address => uint256) public s_vaults;

    /*///////////////////////////////////
               Events
    ///////////////////////////////////*/
    
    /**
     * @notice Emitted when a user makes a deposit
     * @param user Address of the user making the deposit
     * @param amount Amount deposited in wei
     * @param newBalance User's new vault balance after deposit
     */
    event Deposit(address indexed user, uint256 amount, uint256 newBalance);
    
    /**
     * @notice Emitted when a user makes a withdrawal
     * @param user Address of the user making the withdrawal
     * @param amount Amount withdrawn in wei
     * @param newBalance User's new vault balance after withdrawal
     */
    event Withdrawal(address indexed user, uint256 amount, uint256 newBalance);

    /*///////////////////////////////////
               Errors
    ///////////////////////////////////*/
    
    /// @notice Thrown when attempting to deposit zero ETH
    error ZeroDepositNotAllowed();
    
    /// @notice Thrown when a deposit would exceed the bank's capacity
    error BankCapacityExceeded();
    
    /// @notice Thrown when attempting to withdraw zero ETH
    error ZeroWithdrawalNotAllowed();
    
    /// @notice Thrown when attempting to withdraw more than available balance
    error InsufficientVaultBalance();
    
    /// @notice Thrown when attempting to withdraw more than the per-transaction limit
    error WithdrawalLimitExceeded();
    
    /// @notice Thrown when a transfer fails
    error TransferFailed();

    /*///////////////////////////////////
            Modifiers
    ///////////////////////////////////*/
    
    /**
     * @notice Ensures the amount is greater than zero
     * @param _amount Amount to validate
     * @dev Used to prevent zero-value transactions
     */
    modifier validAmount(uint256 _amount) {
        if (_amount == 0) revert ZeroDepositNotAllowed();
        _;
    }

    /*///////////////////////////////////
            Functions
    ///////////////////////////////////*/

    /*/////////////////////////
        constructor
    /////////////////////////*/
    
    /**
     * @notice Initializes the KipuBank contract
     * @param _withdrawalLimit Maximum amount that can be withdrawn per transaction
     * @param _bankCap Maximum total amount that can be deposited in the bank
     * @dev Both parameters are immutable after deployment
     */
    constructor(uint256 _withdrawalLimit, uint256 _bankCap) {
        i_withdrawalLimit = _withdrawalLimit;
        i_bankCap = _bankCap;
    }

    /*/////////////////////////
     Receive & Fallback
    /////////////////////////*/

    /*/////////////////////////
        external
    /////////////////////////*/
    
    /**
     * @notice Allows users to deposit ETH into their personal vault
     * @dev Follows checks-effects-interactions pattern
     * @dev Emits Deposit event on success
     */
    function deposit() external payable validAmount(msg.value) {
        // Checks
        if (s_totalDeposits + msg.value > i_bankCap) {
            revert BankCapacityExceeded();
        }
        
        // Effects
        s_vaults[msg.sender] += msg.value;
        s_totalDeposits += msg.value;
        s_depositCount++;
        
        // Interactions (event emission)
        emit Deposit(msg.sender, msg.value, s_vaults[msg.sender]);
    }
    
    /**
     * @notice Allows users to withdraw ETH from their personal vault
     * @param _amount Amount to withdraw in wei
     * @dev Follows checks-effects-interactions pattern
     * @dev Emits Withdrawal event on success
     */
    function withdraw(uint256 _amount) external validAmount(_amount) {
        // Checks
        if (_amount > s_vaults[msg.sender]) {
            revert InsufficientVaultBalance();
        }
        if (_amount > i_withdrawalLimit) {
            revert WithdrawalLimitExceeded();
        }
        
        // Effects
        s_vaults[msg.sender] -= _amount;
        s_totalDeposits -= _amount;
        s_withdrawalCount++;
        
        // Interactions
        _safeTransfer(msg.sender, _amount);
        
        emit Withdrawal(msg.sender, _amount, s_vaults[msg.sender]);
    }

    /*/////////////////////////
         public
    /////////////////////////*/

    /*/////////////////////////
        internal
    /////////////////////////*/

    /*/////////////////////////
        private
    /////////////////////////*/
    
    /**
     * @notice Safely transfers ETH to a recipient
     * @param _to Address to receive the ETH
     * @param _amount Amount to transfer in wei
     * @dev Uses call method for secure ETH transfers
     * @dev Reverts with TransferFailed if the transfer fails
     */
    function _safeTransfer(address _to, uint256 _amount) private {
        (bool success, ) = payable(_to).call{value: _amount}("");
        if (!success) revert TransferFailed();
    }

    /*/////////////////////////
      View & Pure
    /////////////////////////*/
    
    /**
     * @notice Returns the vault balance for a specific user
     * @param _user Address of the user to check
     * @return User's vault balance in wei
     * @dev View function that doesn't modify state
     */
    function getVaultBalance(address _user) external view returns (uint256) {
        return s_vaults[_user];
    }
    
    /**
     * @notice Returns comprehensive information about the bank's current state
     * @return _totalDeposits Total amount deposited in the bank
     * @return _bankCap Maximum capacity of the bank
     * @return _withdrawalLimit Maximum withdrawal amount per transaction
     * @return _depositCount Total number of deposits made
     * @return _withdrawalCount Total number of withdrawals made
     * @dev View function that provides a snapshot of the bank's state
     */
    function getBankInfo() 
        external 
        view 
        returns (
            uint256 _totalDeposits,
            uint256 _bankCap,
            uint256 _withdrawalLimit,
            uint256 _depositCount,
            uint256 _withdrawalCount
        ) 
    {
        return (
            s_totalDeposits,
            i_bankCap,
            i_withdrawalLimit,
            s_depositCount,
            s_withdrawalCount
        );
    }
}
