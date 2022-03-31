// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

contract Notas {
    address public ownerCatedra;
    mapping(bytes32 => uint) notas;
    string[] revisionesAlumnos;

    constructor(){
        ownerCatedra = msg.sender;
    }

    event alumnoEvaluado(bytes32);
    event pedidoRevision(string);

    modifier onlyOwnerCatedra(address _ownerAddress){
        require(_ownerAddress == ownerCatedra, "No tienes permisos para ejecutar esta funcion.");
        _;
    }

    function evaluar(string memory _idAlumno, uint _nota) public onlyOwnerCatedra(msg.sender) {
        bytes32 hashIdAlumno = keccak256(abi.encodePacked(_idAlumno));
        notas[hashIdAlumno] = _nota;
        emit alumnoEvaluado(hashIdAlumno);
    }

    function getNotas(string memory _idAlumno) public view returns(uint) {
        bytes32 hashIdAlumno = keccak256(abi.encodePacked(_idAlumno));
        return notas[hashIdAlumno];
    }

    function postRevision(string memory _idAlumno) public {
        revisionesAlumnos.push(_idAlumno);
        emit pedidoRevision(_idAlumno);
    }

    function getRevisiones() public view onlyOwnerCatedra(msg.sender) returns(string [] memory)  {
        return revisionesAlumnos;
    }
}