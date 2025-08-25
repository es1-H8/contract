// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CrowdFunding {
    // 投资人结构定义
    struct Funder {
        address payable addr; // 投资人的地址
        uint256 amount;      // 出资数额
    }

    // 资金使用请求结构定义
    struct Use {
        string info;                     // 使用请求的说明
        uint256 goal;                    // 使用请求的数额
        uint256 agreeAmount;             // 目前的同意数额
        uint256 disagree;                // 目前的不同意数额
        bool over;                       // 请求是否结束
        mapping(uint256 => uint256) agree; // 出资人是否同意 0: 还没决定，1：同意，2：不同意
    }

    // 众筹项目的结构定义
    struct Funding {
        address payable initiator; // 发起人
        string title;             // 项目标题
        string info;              // 项目简介
        uint256 goal;             // 目标金额
        uint256 endTime;          // 众筹结束时间
        bool success;             // 众筹是否成功，成功则 amount 含义为项目剩余的钱
        uint256 amount;           // 当前已经筹集到的金额
        uint256 numFunders;       // 投资记录数量
        uint256 numUses;          // 使用请求数量
        mapping(uint256 => Funder) funders; // 投资记录具体信息
        mapping(uint256 => Use) uses;      // 所有的使用请求
    }

    uint256 public numFundings; // 众筹项目数量
    mapping(uint256 => Funding) public fundings; // 所有的众筹项目

    /**
     * 发起众筹项目
     * @param initiator 发起人
     * @param title 项目标题
     * @param info 项目简介
     * @param goal 目标金额
     * @param endTime 结束时间
     */
    function newFunding(address payable initiator, string memory title, string memory info, uint256 goal, uint256 endTime) public returns (uint256) {
        require(endTime > block.timestamp, "End time must be in the future");

        numFundings = numFundings + 1;
        Funding storage f = fundings[numFundings];
        f.initiator = initiator;
        f.title = title;
        f.info = info;
        f.goal = goal;
        f.endTime = endTime;
        f.success = false;
        f.amount = 0;
        f.numFunders = 0;
        f.numUses = 0;

        return numFundings;
    }

    function contribute(uint256 ID) public payable {
        require(ID <= numFundings && ID >= 1, "Invalid funding ID");
        require(msg.value > 0, "Contribution must be greater than zero");
        require(msg.value <= fundings[ID].goal - fundings[ID].amount, "Contribution exceeds remaining goal");
        require(fundings[ID].endTime > block.timestamp, "Funding period has ended");
        require(!fundings[ID].success, "Funding already successful");

        Funding storage f = fundings[ID];
        f.amount += msg.value;
        f.numFunders = f.numFunders + 1;
        f.funders[f.numFunders].addr = payable(msg.sender);
        f.funders[f.numFunders].amount = msg.value;
        f.success = f.amount >= f.goal;
    }

    function returnMoney(uint256 ID) public {
        require(ID <= numFundings && ID >= 1, "Invalid funding ID");
        require(!fundings[ID].success, "Funding is successful, cannot refund");

        Funding storage f = fundings[ID];
        bool contributed = false;
        for (uint256 i = 1; i <= f.numFunders; i++) {
            if (f.funders[i].addr == msg.sender && f.funders[i].amount > 0) {
                contributed = true;
                uint256 amountToRefund = f.funders[i].amount;
                f.funders[i].amount = 0;
                f.amount -= amountToRefund;
                f.funders[i].addr.transfer(amountToRefund);
            }
        }
        require(contributed, "No contribution found for sender");
    }

    function newUse(uint256 ID, uint256 goal, string memory info) public {
        require(ID <= numFundings && ID >= 1, "Invalid funding ID");
        require(fundings[ID].success, "Funding not successful");
        require(goal <= fundings[ID].amount, "Goal exceeds available funds");
        require(msg.sender == fundings[ID].initiator, "Only initiator can create use");

        Funding storage f = fundings[ID];
        f.numUses = f.numUses + 1;
        f.uses[f.numUses].info = info;
        f.uses[f.numUses].goal = goal;
        f.uses[f.numUses].agreeAmount = 0;
        f.uses[f.numUses].disagree = 0;
        f.uses[f.numUses].over = false;
        f.amount = f.amount - goal;
    }

    function agreeUse(uint256 ID, uint256 useID, bool agree) public {
        require(ID <= numFundings && ID >= 1, "Invalid funding ID");
        require(useID <= fundings[ID].numUses && useID >= 1, "Invalid use ID");
        require(!fundings[ID].uses[useID].over, "Use request is over");

        Funding storage f = fundings[ID];
        bool isFunder = false;
        for (uint256 i = 1; i <= f.numFunders; i++) {
            if (f.funders[i].addr == msg.sender) {
                isFunder = true;
                if (f.uses[useID].agree[i] == 1) {
                    f.uses[useID].agreeAmount -= f.funders[i].amount;
                } else if (f.uses[useID].agree[i] == 2) {
                    f.uses[useID].disagree -= f.funders[i].amount;
                }
                if (agree) {
                    f.uses[useID].agreeAmount += f.funders[i].amount;
                    f.uses[useID].agree[i] = 1;
                } else {
                    f.uses[useID].disagree += f.funders[i].amount;
                    f.uses[useID].agree[i] = 2;
                }
                break;
            }
        }
        require(isFunder, "Sender is not a funder");
        checkUse(ID, useID);
    }

    function checkUse(uint256 ID, uint256 useID) public {
        require(ID <= numFundings && ID >= 1, "Invalid funding ID");
        require(useID <= fundings[ID].numUses && useID >= 1, "Invalid use ID");
        require(!fundings[ID].uses[useID].over, "Use request is over");

        Funding storage f = fundings[ID];
        Use storage u = f.uses[useID];
        if (u.agreeAmount >= f.goal / 2) {
            u.over = true;
            f.initiator.transfer(u.goal);
        } else if (u.disagree > f.goal / 2) {
            f.amount = f.amount + u.goal;
            u.over = true;
        }
    }

    function getUseLength(uint256 ID) public view returns (uint256) {
        require(ID <= numFundings && ID >= 1, "Invalid funding ID");
        return fundings[ID].numUses;
    }

    function getUse(uint256 ID, uint256 useID, address addr) public view returns (string memory, uint256, uint256, uint256, bool, uint256) {
        require(ID <= numFundings && ID >= 1, "Invalid funding ID");
        require(useID <= fundings[ID].numUses && useID >= 1, "Invalid use ID");

        Use storage u = fundings[ID].uses[useID];
        uint256 agree = 0;
        for (uint256 i = 1; i <= fundings[ID].numFunders; i++) {
            if (fundings[ID].funders[i].addr == addr) {
                agree = fundings[ID].uses[useID].agree[i];
                break;
            }
        }
        return (u.info, u.goal, u.agreeAmount, u.disagree, u.over, agree);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getMyFundings(address addr, uint256 ID) public view returns (uint256) {
        require(ID <= numFundings && ID >= 1, "Invalid funding ID");
        uint256 res = 0;
        for (uint256 i = 1; i <= fundings[ID].numFunders; i++) {
            if (fundings[ID].funders[i].addr == addr) {
                res += fundings[ID].funders[i].amount;
            }
        }
        return res;
    }
}