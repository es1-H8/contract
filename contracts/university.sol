// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

enum UserRole {
    Student,
    Professor,
    PregradeCoordinator,
    PostgradeCoordinator,
    CareerCoordinator,
    Administrator
}

struct User {
    uint256 id;
    address currentWallet;
    address[] previousWallets;
    UserRole[] roles;
    uint256 campusId;
    uint256 careerId;
    uint256 pensumId;
}

struct Campus {
    uint256 id;
    string name;
}

struct Career {
    uint256 id;
    string name;
    uint256 campusId;
}

struct Pensum {
    uint256 id;
    uint256 careerId;
}

struct Subject {
    uint256 id;
    uint8 credits;
    uint8 semester;
    string name;
}

struct UserSubject {
    uint256 subjectId;
    uint8 grade;
    bool isCompleted;
}

contract University {
    address public owner;
    string public name;

    uint256 public nextUserId;
    mapping(address => User) public users;
    mapping(uint256 => UserSubject[]) public userSubjects; // userId => UserSubject

    uint256 public nextCampusId;
    mapping(uint256 => Campus) public campuses; // campusId => Campus

    uint256 public nextCareerId;
    mapping(uint256 => Career) public careers; // careerId => Career
    mapping(uint256 => uint256) public campusCareersCount;
    mapping(uint256 => uint256[]) public campusCareers; // campusId => careerId[]

    uint256 public nextPensumId;
    mapping(uint256 => Pensum) public pensums; // pensumId => Pensum
    mapping(uint256 => uint256) public careerPensumsCount;
    mapping(uint256 => uint256[]) public careerPensums; // careerId => pensumId[]

    uint256 public nextSubjectId;
    mapping(uint256 => Subject) public subjects; // subjectId => Subject
    mapping(uint256 => uint256) public pensumSubjectsCount;
    mapping(uint256 => uint256[]) public pensumSubjects; // pensumId => subjectId[]

    constructor(string memory _name) {
        owner = msg.sender;
        name = _name;
        nextUserId = 1;
        nextCampusId = 1;
        nextCareerId = 1;
        nextPensumId = 1;
        nextSubjectId = 1;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier onlyStudent() {
        bool isStudent = false;

        for (
            uint256 index = 0;
            index < users[msg.sender].roles.length;
            index++
        ) {
            if (users[msg.sender].roles[index] == UserRole.Student) {
                isStudent = true;
                break;
            }
        }

        require(isStudent, "Only students can call this function");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    function addUser(
        address _address,
        UserRole[] memory _roles,
        uint256 careerId
    ) public onlyOwner {
        require(_address != address(0), "Address must not be zero");
        require(careers[careerId].id != 0, "Career does not exist");
        require(
            careerPensums[careerId].length != 0,
            "Career does not have pensums"
        );

        users[_address] = User({
            id: nextUserId,
            currentWallet: _address,
            previousWallets: new address[](0),
            roles: _roles,
            careerId: careerId,
            pensumId: careerPensums[careerId][
                careerPensums[careerId].length - 1
            ],
            campusId: careers[careerId].campusId
        });

        nextUserId++;
    }

    function getUser(address _address) public view returns (User memory) {
        return users[_address];
    }

    function addCampus(string memory _name) public onlyOwner {
        require(bytes(_name).length > 0, "Campus name cannot be empty");
        require(
            bytes(_name).length <= 100,
            "Campus name cannot be longer than 100 characters"
        );

        campuses[nextCampusId] = Campus({name: _name, id: nextCampusId});

        nextCampusId++;
    }

    function addCareer(
        uint256 _campusId,
        string memory _name
    ) public onlyOwner {
        require(campuses[_campusId].id != 0, "Campus does not exist");
        require(bytes(_name).length > 0, "Career name cannot be empty");
        require(
            bytes(_name).length <= 100,
            "Career name cannot be longer than 100 characters"
        );

        careers[nextCareerId] = Career({
            name: _name,
            campusId: _campusId,
            id: nextCareerId
        });
        campusCareers[_campusId].push(nextCareerId);
        campusCareersCount[_campusId]++;

        nextCareerId++;
    }

    function addPensum(
        uint256 _careerId,
        Subject[] memory _subjects
    ) public onlyOwner {
        require(careers[_careerId].id != 0, "Career does not exist");
        require(_subjects.length > 0, "Pensum must have at least one subject");

        pensums[nextPensumId] = Pensum({careerId: _careerId, id: nextPensumId});
        careerPensums[_careerId].push(nextPensumId);
        careerPensumsCount[_careerId]++;

        for (uint256 i = 0; i < _subjects.length; i++) {
            subjects[nextSubjectId] = Subject({
                id: nextSubjectId,
                credits: _subjects[i].credits,
                semester: _subjects[i].semester,
                name: _subjects[i].name
            });
            pensumSubjects[nextPensumId].push(nextSubjectId);
            pensumSubjectsCount[nextPensumId]++;

            nextSubjectId++;
        }

        nextPensumId++;
    }

    function registerSubjects(uint256[] memory _subjectIds) public onlyStudent {
        require(_subjectIds.length > 0, "Must register at least one subject");

        User storage user = users[msg.sender];

        for (uint256 i = 0; i < _subjectIds.length; i++) {
            require(subjects[_subjectIds[i]].id != 0, "Subject does not exist");

            for (uint256 j = 0; j < userSubjects[user.id].length; j++) {
                require(
                    userSubjects[user.id][j].subjectId != _subjectIds[i],
                    "Subject already registered"
                );
            }

            userSubjects[user.id].push(
                UserSubject({
                    subjectId: _subjectIds[i],
                    grade: 0,
                    isCompleted: false
                })
            );
        }
    }

    function getUserCurrentSubjects(
        address _address
    ) public view returns (Subject[] memory) {
        require(users[_address].id != 0, "User does not exist");

        Subject[] memory currentSubjects = new Subject[](
            userSubjects[users[_address].id].length
        );

        uint256 count = 0;

        for (uint256 i = 0; i < userSubjects[users[_address].id].length; i++) {
            if (!userSubjects[users[_address].id][i].isCompleted) {
                currentSubjects[count] = subjects[
                    userSubjects[users[_address].id][i].subjectId
                ];
                count++;
            }
        }

        Subject[] memory resizedSubjects = new Subject[](count);

        for (uint256 i = 0; i < count; i++) {
            resizedSubjects[i] = currentSubjects[i];
        }

        return resizedSubjects;
    }

    function getUserSubjectsOptions(
        address _address
    ) public view returns (Subject[] memory) {
        require(users[_address].id != 0, "User does not exist");

        Pensum memory pensum = pensums[users[_address].pensumId];

        Subject[] memory subjectsOptions = new Subject[](
            pensumSubjects[pensum.id].length
        );

        uint256 count = 0;

        for (uint256 i = 0; i < pensumSubjects[pensum.id].length; i++) {
            uint256 subjectId = pensumSubjects[pensum.id][i];

            bool include = true;

            for (
                uint256 j = 0;
                j < userSubjects[users[_address].id].length;
                j++
            ) {
                UserSubject memory current = userSubjects[users[_address].id][
                    j
                ];

                if (current.subjectId == subjectId && !current.isCompleted) {
                    include = false;
                    break;
                }

                if (
                    current.subjectId == subjectId &&
                    current.isCompleted &&
                    current.grade >= 6
                ) {
                    include = false;
                    break;
                }
            }

            if (include && subjects[subjectId].semester == 1) {
                subjectsOptions[count] = subjects[subjectId];
                count++;
            }
        }

        Subject[] memory resizedSubjects = new Subject[](count);

        for (uint256 i = 0; i < count; i++) {
            resizedSubjects[i] = subjectsOptions[i];
        }

        return resizedSubjects;
    }
}