//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.0;

import "./interfaces/IERC20.sol";
import "./ownership/Ownable.sol";

contract ERC20 is IERC20, Ownable {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _totalSupply
    ) {
        symbol = _symbol;
        name = _name;
        decimals = _decimals;
        totalSupply = _totalSupply;
        _balances[msg.sender] = _totalSupply;
    }

    function transfer(address _to, uint256 _value)
        external
        override
        returns (bool)
    {
        require(_to != address(0), "ERC20: to address is not valid");
        require(_value <= _balances[msg.sender], "ERC20: insufficient balance");

        _balances[msg.sender] = _balances[msg.sender] - _value;
        _balances[_to] = _balances[_to] + _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function balanceOf(address _owner)
        external
        view
        override
        returns (uint256 balance)
    {
        return _balances[_owner];
    }

    function approve(address _spender, uint256 _value)
        external
        override
        returns (bool)
    {
        _allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external override returns (bool) {
        require(_from != address(0), "ERC20: from address is not valid");
        require(_to != address(0), "ERC20: to address is not valid");
        require(_value <= _balances[_from], "ERC20: insufficient balance");
        require(
            _value <= _allowed[_from][msg.sender],
            "ERC20: transfer from value not allowed"
        );

        _allowed[_from][msg.sender] = _allowed[_from][msg.sender] - _value;
        _balances[_from] = _balances[_from] - _value;
        _balances[_to] = _balances[_to] + _value;

        emit Transfer(_from, _to, _value);

        return true;
    }

    function allowance(address _owner, address _spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint256 _addedValue)
        external
        returns (bool)
    {
        _allowed[msg.sender][_spender] =
            _allowed[msg.sender][_spender] +
            _addedValue;

        emit Approval(msg.sender, _spender, _allowed[msg.sender][_spender]);

        return true;
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue)
        external
        returns (bool)
    {
        uint256 oldValue = _allowed[msg.sender][_spender];

        if (_subtractedValue > oldValue) {
            _allowed[msg.sender][_spender] = 0;
        } else {
            _allowed[msg.sender][_spender] = oldValue - _subtractedValue;
        }

        emit Approval(msg.sender, _spender, _allowed[msg.sender][_spender]);

        return true;
    }

    function mintTo(address _to, uint256 _amount)
        external
        onlyOwner
        returns (bool)
    {
        require(_to != address(0), "ERC20: to address is not valid");

        _balances[_to] = _balances[_to] + _amount;
        totalSupply = totalSupply + _amount;

        emit Transfer(address(0), _to, _amount);

        return true;
    }

    function burn(uint256 _amount) external returns (bool) {
        require(
            _balances[msg.sender] >= _amount,
            "ERC20: insufficient balance"
        );

        _balances[msg.sender] = _balances[msg.sender] - _amount;
        totalSupply = totalSupply - _amount;

        emit Transfer(msg.sender, address(0), _amount);

        return true;
    }

    function burnFrom(address _from, uint256 _amount) external returns (bool) {
        require(_from != address(0), "ERC20: from address is not valid");
        require(_balances[_from] >= _amount, "ERC20: insufficient balance");
        require(
            _amount <= _allowed[_from][msg.sender],
            "ERC20: burn from value not allowed"
        );

        _allowed[_from][msg.sender] = _allowed[_from][msg.sender] - _amount;
        _balances[_from] = _balances[_from] - _amount;
        totalSupply = totalSupply - _amount;

        emit Transfer(_from, address(0), _amount);

        return true;
    }
}
