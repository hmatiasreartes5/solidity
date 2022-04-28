// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

contract Hospital {

    address public direccionHospital;
    address public direccionContrato;

    constructor(address _direccion) {
        direccionHospital = _direccion;
        direccionContrato = address(this);
    }

    mapping(bytes32 => Resultados) resultadosCovid;

    struct Resultados {
        bool diagnostico;
        string codigoIPFS;
    }

    event nuevoResultado(bool, string);

    modifier onlyOwnerHospital(address _direccion) {
        require(_direccion == direccionHospital, "No tienes permisos para ejecutar esta funcion");
        _;
    }

    function resultadosTestCovid(string memory _dniPersona, bool _resultadoCovid, string memory _codigoIPFS) public onlyOwnerHospital(msg.sender) {
        bytes32 hashDniPersona = keccak256(abi.encodePacked(_dniPersona));
        resultadosCovid[hashDniPersona] = Resultados(_resultadoCovid, _codigoIPFS);

        emit nuevoResultado(_resultadoCovid, _codigoIPFS);
    }

    function visualizarResultados(string memory _dniPersona) public view returns (string memory, string memory) {
        bytes32 hashDniPersona = keccak256(abi.encodePacked(_dniPersona));
        string memory resultadoTest;

        if(resultadosCovid[hashDniPersona].diagnostico == true) {
            resultadoTest = "Positivo";
        } else {
            resultadoTest = "Negativo";
        }

        return (resultadoTest, resultadosCovid[hashDniPersona].codigoIPFS);
    }
}