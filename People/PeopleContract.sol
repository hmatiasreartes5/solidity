// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract PeopleContract {
    uint nextId;

    struct Person {
        uint id;
        string name;
        string lastName;
        string identificationNumber;
        uint postalCode;
    }

    Person[] peoples;

    function findIndex(uint _id) internal view returns (uint) {
        for (uint i=0; i<peoples.length; i++) {
            if (peoples[i].id == _id){
                return i;
            }
        }
        revert('Person not found');
    }

    function createPerson (string calldata _name, string calldata _lastName, 
        string calldata _identificationNumber, uint _postalCode) public {
            peoples.push(Person(nextId, _name, _lastName, _identificationNumber, _postalCode));
            nextId++;
        }

    function getPerson(uint _id) public view returns (uint, string memory, string memory,
        string memory, uint) {
            uint index = findIndex(_id);
            return (peoples[index].id, peoples[index].name, peoples[index].lastName,
                peoples[index].identificationNumber, peoples[index].postalCode);
        }

    function updateNameAndLastName(uint _id, string memory _name, string memory _lastName) public{
        uint index = findIndex(_id);
        peoples[index].name = _name;
        peoples[index].lastName = _lastName;
    }

    function deletePerson(uint _id) public {
        uint index = findIndex(_id);
        delete peoples[index];
    }
}