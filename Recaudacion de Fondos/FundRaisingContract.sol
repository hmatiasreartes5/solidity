// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract FundRaising {
    
    uint256 ZERO = 0;

    enum State {
        Opened,
        Closed
    }
    
    struct Contribution {
        address contributor;
        uint256 value;
    }

    struct Project {
        string id;
        string name;
        string description;
        address payable author;
        State state;
        uint256 funds;
        uint fundRaisingGoal;
    }

    Project[] public projects;
    mapping(string => Contribution[]) public contributions;

    event ProjectCreated(
        string projectId,
        string name,
        string description,
        uint256 fundRaisingGoal
    );

    event ProjectFunded(string projectId, uint256 value);
    event ProjectStateChanged(string id, State state);

    modifier isAuthor(uint256 projectIndex) {
        require(
           projects[projectIndex].author == msg.sender,
           "You need to be the project author"
        );
        _;
    }

    modifier isNotAuthor(uint256 projectIndex) {
        require(
             projects[projectIndex].author != msg.sender,
            "As author you can't fund your own project"
        );
        _;
    }

    function createProject(
        string calldata _id,
        string calldata _name,
        string calldata _description,
        uint256 _fundRaisingGoal
    ) public {
        require(_fundRaisingGoal > 0 , "Fund raising goal must be greater than 0");

        projects.push(Project(
            _id,
            _name,
            _description,
            payable(msg.sender),
            State.Opened,
            ZERO,
            _fundRaisingGoal
        ));
        emit ProjectCreated(_id, _name, _description, _fundRaisingGoal);
    }

    function createContribution(
        string memory _projectId
    ) internal {
        contributions[_projectId].push(
            Contribution(
                msg.sender,
                msg.value
            )
        );
    }

    function fundProject(uint256 _projectIndex)
        public
        payable
        isNotAuthor(_projectIndex) {
            Project memory project = projects[_projectIndex];

            require(project.state != State.Closed, "The Project can't receive found");
            require(msg.value > 0, "Fund value must be greater than 0");

            project.author.transfer(msg.value);
            project.funds += msg.value;
            projects[_projectIndex] = project;

            createContribution(project.id);

            emit ProjectFunded(project.id, msg.value);
        }

    function changeProjectState(State _newState, uint256 _projectIndex)
        public
        isAuthor(_projectIndex) {
            Project memory project = projects[_projectIndex];

            require(project.state != _newState, "New state must be different");

            project.state = _newState;
            projects[_projectIndex] = project;

            emit ProjectStateChanged(project.id, _newState);
        }

        function getProjectState(uint256 _projectIndex)
            public
            view
            returns (string memory) {
                uint8 stateId = uint8(projects[_projectIndex].state);
                return stateId == 0 ? "Opened" : "Closed";
            }
}