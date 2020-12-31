/*
    Copyright 2020 True Seigniorage Dollar Devs, based on the works of the Empty Set Squad and Dynamic Dollar Devs

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "./Market.sol";
import "./Regulator.sol";
import "./Bonding.sol";
import "./Govern.sol";
import "../Constants.sol";

contract Implementation is State, Bonding, Market, Regulator, Govern {
    using SafeMath for uint256;

    event Advance(uint256 indexed epoch, uint256 block, uint256 timestamp);
    event Incentivization(address indexed account, uint256 amount);

    function initialize() initializer public {
        // committer reward:
        mintToAccount(msg.sender, 100e18); // 100 TSD to committer
        // contributor  rewards:
        mintToAccount(0xF240CdBAE37660ba61ca65b887b8D8091d677b31, 500e18); // 500 TSD to devnull
        mintToAccount(0x5d5D6B228d8A2ADF2067C8a6B78960FF522224b9,  400e18); //  400 TSD to John
        mintToAccount(0xE95bB97850092203B6a5BC6d057288Ab085465B3,  400e18); //  400 TSD to Dr. Dev
    }

    function advance() external incentivized {
        Bonding.step();
        Regulator.step();
        Market.step();

        emit Advance(epoch(), block.number, block.timestamp);
    }

    modifier incentivized {
        // Mint advance reward to sender
        uint256 incentive = Constants.getAdvanceIncentive();
        mintToAccount(msg.sender, incentive);
        emit Incentivization(msg.sender, incentive);
        _;
    }
}
