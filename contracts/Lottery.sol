pragma solidity 0.4.18;

import "./helper_contracts/zeppelin/Ownable.sol";


/** @title Ethereum Lottery Smart Contract. */
contract Lottery is Ownable {
    uint internal numTickets;
    uint internal availTickets;
    uint internal ticketPrice;
    uint internal winningAmount;
    bool internal gameStatus;
    uint internal counter;

    mapping (uint => address) internal players;
    mapping (address => bool) internal playerAddresses;

    event Winner(uint indexed counter, address indexed winner, string mesg); 

    /** @dev returns the Lotter status.
      * @return numTickets The total # of lottery tickets.
      * @return availTickets The # of available tickets.
      * @return ticketPrice The price for one lottery ticket.
      * @return gameStatus The Status of lottery game.
      * @return contractBalance The total available balance of the contract.
    */
    function getLotteryStatus() public view returns(uint, uint, uint, bool, uint) {
        return (numTickets, availTickets, ticketPrice, gameStatus, winningAmount);
    }

    /** @dev inititates the lottery game with #tickets and ticket price.
      * @param tickets - no of max tickets.
      * @param price - price of the ticket.
    */
    function startLottery(uint tickets, uint price) public payable onlyOwner {
        if (tickets <= 1) {
            revert();
        }
        if (price == 0) {
            revert();
        }
        if (msg.value < price) {
            revert();
        }
        numTickets = tickets;
        ticketPrice = price;
        availTickets = numTickets - 1;
        players[++counter] = owner;
        winningAmount += msg.value;
        gameStatus = true;
        playerAddresses[owner] = true;
    }

    /** @dev play lottery game. */
    function playLottery() public payable {
        if (playerAddresses[msg.sender]) {
            revert();
        }
        if (msg.value < ticketPrice) {
            revert();
        }
        if (!gameStatus) {
            revert();
        }
        availTickets = availTickets - 1;
        players[++counter] = msg.sender;
        winningAmount += msg.value;
        playerAddresses[msg.sender] = true;
        if (availTickets == 0) {
            resetLottery();
        }
    }

    /** @dev getter function for gameStatus.
      * @return gameStatus - current status of lottery game.
    */
    function getGameStatus() public view returns(bool) {
        return gameStatus;
    }

    /** @dev endLottery function.
    */
    function endLottery() public onlyOwner {
        resetLottery();
    }
    
    /** @dev getWinner function.
      * this calls getRandomNumber function and
      * finds the winner using players mapping
    */
    function getWinner() internal {
        uint winnerIndex = getRandomNumber();
        address winnerAddress = players[winnerIndex];
        Winner(winnerIndex, winnerAddress, "Winner Found!");
    }

    /** @dev resetLotter function.
    */
    function getRandomNumber() internal view returns(uint) {
        uint random = uint(block.blockhash(block.number-1))%counter + 1;
        return random;
    }

    /** @dev resetLotter function.
    */
    function resetLottery() internal {
        gameStatus = false;
        getWinner();
        winningAmount = 0;
        numTickets = 0;
        availTickets = 0;
        ticketPrice = 0;
        counter = 0;
    }

}