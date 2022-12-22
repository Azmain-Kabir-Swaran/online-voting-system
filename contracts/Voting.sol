// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract OnlineVoting {

    address public organizerName;

    string public electName;

    string public winnerName;



    uint public endTime;

    bool public isStarted;


    address [] public votersAddresses;


    Candidate [] public candidates;

    mapping(address => Voter) public voters;


    struct Candidate {
        string candidateName ;
        uint voteCount;
        address [] voterAddressForCandidate;
    }

    struct Voter {
        bool isVoted;
        bool votingPermission;
        uint votingCandidateNumber;
    }


    constructor (string memory electionName) {
        organizerName = msg.sender;
        electName = electionName;
    }

    function start (uint duration) public {
        require(msg.sender == organizerName, "Only organizer is allowd to start the voting.");
        endTime = block.timestamp + duration*1 minutes;
        isStarted = true;
    }


    function addCandidate (string memory addName) public {
        require(msg.sender == organizerName, "Only organizer is allowd to add candidates.");
        require(isStarted == false, "You cannot add a candidate at this moment.");

        bool isCandidateExist = false;

        for (uint i=0; i<getCandidateNumbers(); i++) {
            if (keccak256(bytes(candidates[i].candidateName)) == keccak256(bytes(addName))) {

                isCandidateExist = true;
                break;
            }
        }

        require(isCandidateExist == false, "This candidate is already added.");

        candidates.push(Candidate(addName, 0, new address[](0)));
    }


    function addPermissionForVote(address voter) public {
        require(msg.sender == organizerName, "Only organizer can add voters.");
        require(isStarted == false, "You cannot add a voter at this moment.");
        require(voters[voter].votingPermission == false, "This address is already authorized to give a vote.");

        voters[voter].votingPermission = true;
    }


    function vote(uint chosenCandidate) public {
        require(voters[msg.sender].votingPermission == true, "You are not authorized to give a vote.");
        require(block.timestamp < endTime, "Time is up! You cannot vote now.");
        require (isStarted == true, "Voting has not been started yet!");
        require(voters[msg.sender].isVoted == false, "Your voting is already done.");
        require(chosenCandidate < getCandidateNumbers(), "Please enter a valid candidate number.");

        voters[msg.sender].votingCandidateNumber = chosenCandidate;
        voters[msg.sender].isVoted = true;

        uint candidateIndex = voters[msg.sender].votingCandidateNumber;
        candidates[candidateIndex].voterAddressForCandidate.push(msg.sender);

        votersAddresses.push(msg.sender);

    }


    function resultCount() public {
        require(isStarted == true, "Result can be seen after voting ends.");
        require(block.timestamp > endTime, "Election is running. Result can be seen after it ends!");
        uint votersNumberWhoVoted = getGivenVotersNumber();

        for (uint i=0; i<votersNumberWhoVoted; i++) {
            address voterAddress = votersAddresses[i];
            uint candidateIndex = voters[voterAddress].votingCandidateNumber;

            candidates[candidateIndex].voteCount++;
        }
        uint voteCountMax = 0;
        uint maxVotedCandidate;

        uint candidateNumbers = getCandidateNumbers();

        for (uint i=0; i<candidateNumbers; i++) {
            if (candidates[i].voteCount > voteCountMax) {
                voteCountMax = candidates[i].voteCount;
                maxVotedCandidate = i;
                winnerName = candidates[maxVotedCandidate].candidateName;
            }
            else if (candidates[i].voteCount == voteCountMax) {
                winnerName = "There is a tie.";
            }
        }

    }



    function getCandidateNumbers() public view returns(uint) {
        return candidates.length;
    }


    function getGivenVotersNumber() public view returns(uint) {
        return votersAddresses.length;
    }

}