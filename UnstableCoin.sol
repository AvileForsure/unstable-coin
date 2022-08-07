// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StableAvile is ERC20, ERC20Burnable, Ownable {
    address liquiditypool;
    address pairtoken;

    constructor(string memory _tokenName, string memory _tokenSymbol, address _pairTokenAddress) ERC20(_tokenName, _tokenSymbol) {
        pairtoken = _pairTokenAddress;
        liquiditypool = 0x0000000000000000000000000000000000000000;
    }

    modifier regulate {
        if(liquiditypool != 0x0000000000000000000000000000000000000000) {
            uint256 usdc = IERC20(pairtoken).balanceOf(liquiditypool);
            uint256 usc = IERC20(address(this)).balanceOf(liquiditypool);
            if(usdc>usc) {
                uint256 result = usdc-usc;
                transfer(liquiditypool,result);
            } else if(usdc<usc) {
                uint256 result = usc-usdc;
                IERC20(pairtoken).transfer(liquiditypool,result);
            }
        }
        _;
    }

    function transfer(address to, uint256 amount) public virtual override regulate returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function mint(address to, uint256 amount) public onlyOwner regulate {
        _mint(to, amount);
    }

    function changePairToken(address _newToken) public onlyOwner {
        pairtoken = _newToken;
    }

    function changeLiquidityPool(address _newLiquidityPool) public onlyOwner {
        liquiditypool = _newLiquidityPool;
    }

}
