// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

contract Votacion{
    address owner;

    constructor() {
        owner = msg.sender;
    }

    struct Candidato {
        string id;
        uint8 edad;
        string nombre;
    }

    struct resultadoVotacion{
        string nombre;
        uint totalVotos;
    }

    mapping (string => bytes32) idCandidato;
    mapping (string => uint) totalVotos;
    bytes32 [] votantes;
    Candidato [] candidatos;
    resultadoVotacion[] resultadosVotaciones;

    modifier checkCandidato(string memory _idCandidato, string memory _nombreCandidato, uint8 _edadCandidato) {
        require(idCandidato[_nombreCandidato] != keccak256(abi.encodePacked(_idCandidato, _nombreCandidato, _edadCandidato)), "El candidato ya existe");
        require(_edadCandidato >= 21, "El candidato debe ser mayor a 21 anios");
        _;
    }

    function postularse(string memory _idCandidato, string memory _nombreCandidato, uint8 _edadCandidato) public checkCandidato(_idCandidato, _nombreCandidato, _edadCandidato){
        bytes32 hashCandidato = keccak256(abi.encodePacked(_idCandidato, _nombreCandidato, _edadCandidato));
        idCandidato[_nombreCandidato] = hashCandidato;
        candidatos.push(Candidato(
            _idCandidato,
            _edadCandidato,
            _nombreCandidato
        ));
    }

    function getCandidatos() public view returns(Candidato[] memory) {
        return candidatos;
    }

    modifier checkVoto(address _addressVotante) {
        bytes32 hashVotante = keccak256(abi.encodePacked(msg.sender));
        for (uint i=0; i<votantes.length; i++) {
            require(votantes[i] != hashVotante, "Ya votaste");
        }
        votantes.push(hashVotante);
        _;
    }

    function postEmitirVoto(string memory _nombreCandidato) public checkVoto(msg.sender){
        totalVotos[_nombreCandidato]++;
    }

    function getVotos(string memory _nombreCandidato) public view returns(uint) {
        return totalVotos[_nombreCandidato];
    }

    function getResultadoVotacion() public returns(resultadoVotacion[] memory ) {
        for (uint i=0; i<candidatos.length; i++) {
            resultadosVotaciones.push(resultadoVotacion(
                candidatos[i].nombre,
                getVotos(candidatos[i].nombre)
            ));
        }
        return resultadosVotaciones;
    }

    function getGanador() public view returns(string memory) {
        string memory ganador = candidatos[0].nombre;
        bool flag;

        for (uint i=0; i<candidatos.length; i++) {
            if (totalVotos[ganador] < totalVotos[candidatos[i].nombre]) {
                ganador = candidatos[i].nombre;
                flag = false;
            } else {
                if(totalVotos[ganador] == totalVotos[candidatos[i].nombre]) {
                    flag = true;
                }
            }
        }

        if (flag == true) {
            ganador = "Hay empate entre los candidatos";
        }

        return ganador;
    }
}